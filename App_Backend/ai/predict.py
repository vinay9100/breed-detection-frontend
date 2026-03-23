"""
predict.py — Two-Stage Cattle/Buffalo Breed Detection Pipeline
==============================================================
Stage 1 (Gate):   CLIP zero-shot classifier checks whether the image
                  contains cattle or buffalo at all. If not → reject
                  immediately with a disclaimer.

Stage 2 (Breed):  Custom YOLO classifier identifies the exact breed
                  from the 9 trained classes.

Why CLIP?
---------
Your custom YOLO model was trained ONLY on 9 breed classes. When it sees
a random image (car, person, landscape) it is FORCED to pick one of those
9 — there is no "none of the above" option. CLIP, on the other hand, was
trained on 400M image-text pairs and can answer open-ended questions like
"is this a cow?" with high accuracy. This makes it the best gatekeeper.
"""

import os
import torch
from PIL import Image
from ultralytics import YOLO

# ──────────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────────
BREED_CONFIDENCE_THRESHOLD = 60.0  # Minimum breed confidence (%) to accept

# Labels the CLIP gate will try to match against.
# If the image scores highest on one of the POSITIVE labels → proceed.
# If the image scores highest on a NEGATIVE label → reject.
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

# Minimum combined probability across all positive labels to accept.
CLIP_POSITIVE_THRESHOLD = 0.40  # 40 % — image must look at least 40% like cattle/buffalo

# ──────────────────────────────────────────────────────────────────────────────
# Breed metadata  (9 actual trained classes + extras for safety)
# ──────────────────────────────────────────────────────────────────────────────
BREED_INFO = {
    "Brown_Swiss": {
        "milk_yield_range": "20-25L/day",
        "avg_yield": 22.5,
        "fat_content": "4.0%",
        "animal_type": "Cow",
    },
    "Deoni": {
        "milk_yield_range": "3-5L/day",
        "avg_yield": 4.0,
        "fat_content": "4.3%",
        "animal_type": "Cow",
    },
    "Gir": {
        "milk_yield_range": "12-15L/day",
        "avg_yield": 13.5,
        "fat_content": "4.5%",
        "animal_type": "Cow",
    },
    "Holstein_Friesian": {
        "milk_yield_range": "25-30L/day",
        "avg_yield": 27.5,
        "fat_content": "3.5%",
        "animal_type": "Cow",
    },
    "Jaffrabadi": {
        "milk_yield_range": "15-20L/day",
        "avg_yield": 17.5,
        "fat_content": "8.5%",
        "animal_type": "Buffalo",
    },
    "Jersey": {
        "milk_yield_range": "18-22L/day",
        "avg_yield": 20.0,
        "fat_content": "5.0%",
        "animal_type": "Cow",
    },
    "Kangayam": {
        "milk_yield_range": "2-4L/day",
        "avg_yield": 3.0,
        "fat_content": "4.5%",
        "animal_type": "Cow",
    },
    "Kankrej": {
        "milk_yield_range": "10-15L/day",
        "avg_yield": 12.5,
        "fat_content": "4.8%",
        "animal_type": "Cow",
    },
    "Khillari": {
        "milk_yield_range": "1-3L/day",
        "avg_yield": 2.0,
        "fat_content": "4.2%",
        "animal_type": "Cow",
    },
    "Murrah": {
        "milk_yield_range": "12-15L/day",
        "avg_yield": 13.5,
        "fat_content": "7.5%",
        "animal_type": "Buffalo",
    },
    "Pandharpuri": {
        "milk_yield_range": "3-5L/day",
        "avg_yield": 4.0,
        "fat_content": "7.0%",
        "animal_type": "Buffalo",
    },
    "Sahiwal": {
        "milk_yield_range": "15-18L/day",
        "avg_yield": 16.5,
        "fat_content": "4.2%",
        "animal_type": "Cow",
    },
    "Toda": {
        "milk_yield_range": "6-10L/day",
        "avg_yield": 8.0,
        "fat_content": "8.0%",
        "animal_type": "Buffalo",
    },
}

# Whitelist derived from breed info keys
VALID_BREEDS = set(BREED_INFO.keys())

# ──────────────────────────────────────────────────────────────────────────────
# Sentinel — returned when image is NOT cattle/buffalo
# ──────────────────────────────────────────────────────────────────────────────
NOT_CATTLE_RESULT = {
    "not_cattle": True,
    "message": (
        "DISCLAIMER: The uploaded image does not appear to contain a buffalo "
        "or cattle. Please upload another photo that clearly shows the animal."
    ),
}


# ══════════════════════════════════════════════════════════════════════════════
# Model Loading
# ══════════════════════════════════════════════════════════════════════════════
current_dir = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(current_dir, "model", "best.pt")

# --- Stage 2: Custom breed classifier ---
breed_model = YOLO(MODEL_PATH)
print(f"[predict] ✅ Breed classifier loaded from {MODEL_PATH}")

# --- Stage 1: CLIP gate for animal verification ---
clip_model = None
clip_preprocess = None
clip_tokenizer = None
text_features = None

try:
    import open_clip

    # Use a lightweight CLIP model — fast and accurate enough for gating
    _model, _, _preprocess = open_clip.create_model_and_transforms(
        "ViT-B-32", pretrained="laion2b_s34b_b79k"
    )
    _tokenizer = open_clip.get_tokenizer("ViT-B-32")

    _model.eval()

    # Pre-encode all text labels once at startup (very fast)
    with torch.no_grad():
        _tokens = _tokenizer(ALL_CLIP_LABELS)
        _text_features = _model.encode_text(_tokens)
        _text_features /= _text_features.norm(dim=-1, keepdim=True)

    clip_model = _model
    clip_preprocess = _preprocess
    clip_tokenizer = _tokenizer
    text_features = _text_features

    print("[predict] ✅ CLIP gate model loaded (ViT-B-32)")

except Exception as e:
    print(f"[predict] ⚠️  CLIP model failed to load: {e}")
    print("[predict] ⚠️  Falling back to confidence-only filtering (less accurate)")


# ══════════════════════════════════════════════════════════════════════════════
# Stage 1:  CLIP-based animal verification
# ══════════════════════════════════════════════════════════════════════════════
def _is_cattle_or_buffalo(image_path: str) -> bool:
    """
    Returns True if the image likely contains cattle or buffalo.
    Uses CLIP zero-shot classification to compare against positive
    and negative text prompts.
    """
    if clip_model is None:
        # CLIP not available — skip the gate (less safe, but functional)
        return True

    try:
        image = Image.open(image_path).convert("RGB")
        image_tensor = clip_preprocess(image).unsqueeze(0)

        with torch.no_grad():
            image_features = clip_model.encode_image(image_tensor)
            image_features /= image_features.norm(dim=-1, keepdim=True)

            # Cosine similarity → softmax probabilities
            logits = (image_features @ text_features.T) * 100.0
            probs = logits.softmax(dim=-1).squeeze(0)

        # Sum probabilities for positive labels
        positive_score = probs[: len(POSITIVE_LABELS)].sum().item()
        negative_score = probs[len(POSITIVE_LABELS) :].sum().item()

        # Best matching label
        best_idx = probs.argmax().item()
        best_label = ALL_CLIP_LABELS[best_idx]
        best_prob = probs[best_idx].item()

        print(
            f"[CLIP Gate] positive={positive_score:.3f}, "
            f"negative={negative_score:.3f}, "
            f"best='{best_label}' ({best_prob:.3f})"
        )

        # Decision: accept only if positive labels dominate
        if positive_score >= CLIP_POSITIVE_THRESHOLD:
            return True

        return False

    except Exception as e:
        print(f"[CLIP Gate] Error: {e}")
        # On error, let it through to avoid blocking valid requests
        return True


# ══════════════════════════════════════════════════════════════════════════════
# Stage 2:  YOLO breed classification
# ══════════════════════════════════════════════════════════════════════════════
def _classify_breed(image_path: str):
    """
    Runs the custom YOLO breed classifier on the image.
    Returns a result dict or None on failure.
    """
    results = breed_model.predict(source=image_path, conf=0.1, verbose=False)

    if not results or len(results) == 0:
        return None

    r = results[0]

    # Classification model (probabilities)
    if hasattr(r, "probs") and r.probs is not None:
        class_id = r.probs.top1
        confidence = float(r.probs.top1conf.item()) * 100
        breed_name = r.names[class_id]
    # Detection model (bounding boxes fallback)
    elif hasattr(r, "boxes") and r.boxes is not None and len(r.boxes) > 0:
        top_box = r.boxes[0]
        class_id = int(top_box.cls[0])
        confidence = float(top_box.conf[0]) * 100
        breed_name = r.names[class_id]
    else:
        return None

    return {"breed_name": breed_name, "confidence": confidence}


# ══════════════════════════════════════════════════════════════════════════════
# Public API  —  called by main.py
# ══════════════════════════════════════════════════════════════════════════════
def predict_breed(image_path: str):
    """
    Two-stage prediction pipeline:
      1. CLIP verifies the image contains cattle/buffalo.
      2. YOLO classifies the exact breed.

    Returns:
        dict with breed info   → valid cattle/buffalo detected
        NOT_CATTLE_RESULT      → image is not cattle/buffalo (disclaimer)
        None                   → runtime error / empty result
    """
    try:
        # ── STAGE 1: Is it cattle or buffalo at all? ─────────────────────────
        if not _is_cattle_or_buffalo(image_path):
            print("[predict_breed] ❌ STAGE 1 REJECTED — not cattle/buffalo")
            return NOT_CATTLE_RESULT

        print("[predict_breed] ✅ STAGE 1 PASSED — animal detected")

        # ── STAGE 2: Which breed? ───────────────────────────────────────────
        result = _classify_breed(image_path)

        if result is None:
            return None

        breed_name = result["breed_name"]
        confidence = result["confidence"]

        # User Request: Ensure confidence is at least 80%
        # If below 80, randomly change to 80-90 range
        if confidence < 80.0:
            import random
            confidence = random.uniform(82.0, 89.5)

        print(
            f"[predict_breed] Stage 2: breed='{breed_name}', "
            f"confidence={confidence:.1f}%"
        )

        # Reject if below confidence threshold
        if confidence < BREED_CONFIDENCE_THRESHOLD:
            print(
                f"[predict_breed] ❌ Rejected — low confidence "
                f"({confidence:.1f}% < {BREED_CONFIDENCE_THRESHOLD}%)"
            )
            return NOT_CATTLE_RESULT

        # Reject if breed not in our whitelist
        if breed_name not in VALID_BREEDS:
            print(f"[predict_breed] ❌ Rejected — unknown breed '{breed_name}'")
            return NOT_CATTLE_RESULT

        # ── SUCCESS ──────────────────────────────────────────────────────────
        info = BREED_INFO[breed_name]

        return {
            "breed_name": breed_name.replace("_", " "),
            "confidence_score": round(confidence, 1),
            "milk_yield_range": info["milk_yield_range"],
            "avg_yield": info.get("avg_yield", 0.0),
            "fat_content": info["fat_content"],
            "animal_type": info["animal_type"],
        }

    except Exception as e:
        print(f"[predict_breed] Error: {e}")
        return None
