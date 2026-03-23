"""
AI Training Backend — main.py
==============================
Uses the same two-stage pipeline (CLIP gate → YOLO breed classifier)
for the /predict endpoint.
"""

from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from ultralytics import YOLO
import os
import shutil
import time
from typing import Optional

# Import the shared prediction logic
# We'll use a local copy of the same pipeline here
import torch
from PIL import Image

app = FastAPI(title="BSAI AI Training Backend")

MODEL_PATH = "models_ai/best.pt"
DATASET_PATH = "data"

# ──────────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────────
BREED_CONFIDENCE_THRESHOLD = 60.0

POSITIVE_LABELS = [
    "a photo of a cow",
    "a photo of a buffalo",
    "a photo of cattle",
    "a photo of a bull",
    "a photo of a calf",
    "a photo of a dairy cow",
    "a photo of an ox",
    "a photo of a water buffalo",
]
NEGATIVE_LABELS = [
    "a photo of a person",
    "a photo of a car",
    "a photo of a building",
    "a photo of food",
    "a photo of a dog",
    "a photo of a cat",
    "a photo of a landscape",
    "a photo of an object",
    "a photo of text or document",
    "a photo of electronics",
]
ALL_CLIP_LABELS = POSITIVE_LABELS + NEGATIVE_LABELS
CLIP_POSITIVE_THRESHOLD = 0.40

# Breed Data for ML mapping
BREED_INFO = {
    "Brown_Swiss":       {"Type": "Cow",     "Milk": 22.0, "Fat": "4.0%"},
    "Deoni":             {"Type": "Cow",     "Milk": 4.0,  "Fat": "4.3%"},
    "Gir":               {"Type": "Cow",     "Milk": 13.5, "Fat": "4.5%"},
    "Holstein_Friesian": {"Type": "Cow",     "Milk": 27.5, "Fat": "3.5%"},
    "Jaffrabadi":        {"Type": "Buffalo", "Milk": 17.5, "Fat": "8.5%"},
    "Jersey":            {"Type": "Cow",     "Milk": 20.0, "Fat": "5.0%"},
    "Kangayam":          {"Type": "Cow",     "Milk": 3.0,  "Fat": "4.5%"},
    "Kankrej":           {"Type": "Cow",     "Milk": 12.5, "Fat": "4.8%"},
    "Khillari":          {"Type": "Cow",     "Milk": 2.0,  "Fat": "4.2%"},
    "Murrah":            {"Type": "Buffalo", "Milk": 13.5, "Fat": "7.5%"},
    "Pandharpuri":       {"Type": "Buffalo", "Milk": 4.0,  "Fat": "7.0%"},
    "Sahiwal":           {"Type": "Cow",     "Milk": 16.5, "Fat": "4.2%"},
    "Toda":              {"Type": "Buffalo", "Milk": 8.0,  "Fat": "8.0%"},
}

VALID_BREEDS = set(BREED_INFO.keys())

NOT_CATTLE_RESULT = {
    "not_cattle": True,
    "message": (
        "DISCLAIMER: The uploaded image does not appear to contain a buffalo "
        "or cattle. Please upload another photo that clearly shows the animal."
    ),
}

# ──────────────────────────────────────────────────────────────────────────────
# Model Loading
# ──────────────────────────────────────────────────────────────────────────────
# YOLO breed classifier
try:
    if os.path.exists(MODEL_PATH):
        yolo_model = YOLO(MODEL_PATH)
        print(f"[AI] ✅ Breed model loaded from {MODEL_PATH}")
    else:
        yolo_model = None
        print(f"[AI] ⚠️  Model not found at {MODEL_PATH}")
except Exception as e:
    yolo_model = None
    print(f"[AI] Error loading breed model: {e}")

# CLIP gate model
clip_model = None
clip_preprocess = None
text_features = None

try:
    import open_clip

    _model, _, _preprocess = open_clip.create_model_and_transforms(
        "ViT-B-32", pretrained="laion2b_s34b_b79k"
    )
    _tokenizer = open_clip.get_tokenizer("ViT-B-32")
    _model.eval()

    with torch.no_grad():
        _tokens = _tokenizer(ALL_CLIP_LABELS)
        _text_features = _model.encode_text(_tokens)
        _text_features /= _text_features.norm(dim=-1, keepdim=True)

    clip_model = _model
    clip_preprocess = _preprocess
    text_features = _text_features
    print("[AI] ✅ CLIP gate model loaded (ViT-B-32)")

except Exception as e:
    print(f"[AI] ⚠️  CLIP model failed: {e}. Using confidence-only fallback.")


# ──────────────────────────────────────────────────────────────────────────────
# Stage 1: CLIP Gate
# ──────────────────────────────────────────────────────────────────────────────
def is_cattle_or_buffalo(image_path: str) -> bool:
    if clip_model is None:
        return True  # Skip gate if CLIP unavailable

    try:
        image = Image.open(image_path).convert("RGB")
        image_tensor = clip_preprocess(image).unsqueeze(0)

        with torch.no_grad():
            image_features = clip_model.encode_image(image_tensor)
            image_features /= image_features.norm(dim=-1, keepdim=True)
            logits = (image_features @ text_features.T) * 100.0
            probs = logits.softmax(dim=-1).squeeze(0)

        positive_score = probs[:len(POSITIVE_LABELS)].sum().item()
        best_idx = probs.argmax().item()
        best_label = ALL_CLIP_LABELS[best_idx]

        print(f"[CLIP] positive={positive_score:.3f}, best='{best_label}' ({probs[best_idx]:.3f})")

        return positive_score >= CLIP_POSITIVE_THRESHOLD

    except Exception as e:
        print(f"[CLIP] Error: {e}")
        return True  # Let through on error


# ──────────────────────────────────────────────────────────────────────────────
# Training status
# ──────────────────────────────────────────────────────────────────────────────
training_status = {"status": "idle", "progress": 0, "last_error": None}


@app.get("/")
def read_root():
    return {"status": "AI Training Backend is running", "model_loaded": yolo_model is not None}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if not yolo_model:
        raise HTTPException(status_code=503, detail="AI Model is not loaded on the server.")

    temp_file = f"temp_{int(time.time())}_{file.filename}"

    try:
        with open(temp_file, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # ── STAGE 1: CLIP gate — is it cattle/buffalo? ───────────────────────
        if not is_cattle_or_buffalo(temp_file):
            return NOT_CATTLE_RESULT

        # ── STAGE 2: YOLO breed classification ───────────────────────────────
        results = yolo_model(temp_file, verbose=False)

        if len(results) == 0:
            raise HTTPException(status_code=400, detail="Could not analyze image.")

        r = results[0]

        if hasattr(r, "probs") and r.probs is not None:
            top_index = r.probs.top1
            breed_name = r.names[top_index]
            confidence = float(r.probs.top1conf.item() * 100)
        else:
            breed_name = "Unknown"
            confidence = 0.0

        # Reject if confidence too low
        if confidence < BREED_CONFIDENCE_THRESHOLD:
            return NOT_CATTLE_RESULT

        # Reject if breed not in whitelist
        if breed_name not in VALID_BREEDS:
            return NOT_CATTLE_RESULT

        info = BREED_INFO.get(breed_name, {"Type": "Unknown", "Milk": 0.0, "Fat": "N/A"})

        return {
            "breed_name": breed_name.replace("_", " "),
            "confidence_score": confidence,
            "animal_type": info["Type"],
            "milk_yield_range": f"{info['Milk']} Litres/day",
            "fat_content": info["Fat"],
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)


def train_model_task(epochs: int, data_yaml: str):
    global training_status
    try:
        training_status["status"] = "training"
        training_status["progress"] = 0

        model = YOLO(MODEL_PATH if os.path.exists(MODEL_PATH) else "yolov8n.pt")
        results = model.train(data=data_yaml, epochs=epochs, imgsz=640)

        if not os.path.exists("models_ai"):
            os.makedirs("models_ai")
        shutil.copy(os.path.join(results.save_dir, "weights", "best.pt"), MODEL_PATH)

        global yolo_model
        yolo_model = YOLO(MODEL_PATH)

        training_status["status"] = "completed"
        training_status["progress"] = 100
    except Exception as e:
        training_status["status"] = "failed"
        training_status["last_error"] = str(e)
        print(f"Training failed: {e}")


@app.post("/train")
async def train_model(background_tasks: BackgroundTasks, epochs: int = 10, data_yaml: Optional[str] = None):
    global training_status
    if training_status["status"] == "training":
        return {"message": "Training is already in progress"}

    yaml_to_use = data_yaml or os.path.join(os.getcwd(), "data.yaml")
    if not os.path.exists(yaml_to_use):
        raise HTTPException(status_code=400, detail=f"Data YAML file not found at {yaml_to_use}")

    background_tasks.add_task(train_model_task, epochs, yaml_to_use)
    return {"message": "Training started in background", "status_url": "/train/status"}


@app.get("/train/status")
def get_train_status():
    return training_status
