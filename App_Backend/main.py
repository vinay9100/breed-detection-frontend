import fastapi
from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Form, BackgroundTasks
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from sqlalchemy import func, or_
from database import engine, Base, get_db
import models, schemas, utils, security, mailer
from ai.predict import predict_breed, NOT_CATTLE_RESULT
from datetime import datetime, timedelta
from typing import List, Optional
import os, shutil
import jwt
import httpx

# Configuration for AI Backend
AI_BACKEND_URL = os.getenv("AI_BACKEND_URL", "http://localhost:8001")

# Breed Data for ML mapping (Shared for metadata)
BREED_INFO = {
    "Brown_Swiss":       {"Type": "Cow", "Milk": 22.0, "Fat": "4.0%"},
    "Deoni":             {"Type": "Cow", "Milk": 4.0,  "Fat": "4.3%"},
    "Gir":               {"Type": "Cow", "Milk": 13.5, "Fat": "4.5%"},
    "Holstein_Friesian": {"Type": "Cow", "Milk": 27.5, "Fat": "3.5%"},
    "Jaffrabadi":        {"Type": "Buffalo", "Milk": 17.5, "Fat": "8.5%"},
    "Kangayam":          {"Type": "Cow", "Milk": 3.0,  "Fat": "4.5%"},
    "Kankrej":           {"Type": "Cow", "Milk": 12.5, "Fat": "4.8%"},
    "Khillari":          {"Type": "Cow", "Milk": 2.0,  "Fat": "4.2%"},
    "Murrah":            {"Type": "Buffalo", "Milk": 13.5, "Fat": "7.5%"},
    "Sahiwal":           {"Type": "Cow", "Milk": 16.5, "Fat": "4.2%"},
    "Toda":              {"Type": "Buffalo", "Milk": 8.0,  "Fat": "8.0%"},
}


# Create database tables
models.Base.metadata.create_all(bind=engine)

def get_clean_email(email: str) -> str:
    """Trim whitespace and strip BPA- prefix if present."""
    email = email.strip()
    if email.upper().startswith("BPA-"):
        return email[4:].strip()
    return email

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="BSAI App Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Ensure uploads directory exists
UPLOAD_DIR = "uploads"
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

# Mount static files to serve uploaded images
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

@app.get("/")
def read_root():
    return {"status": "BSAI App Backend is running"}

@app.post("/register", response_model=dict)
async def register(user: schemas.UserCreate, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_email = get_clean_email(user.email)
    db_user = db.query(models.User).filter(models.User.email == clean_email).first()
    
    hashed_password = security.get_password_hash(user.password)
    otp = utils.generate_otp()
    otp_created_at = datetime.utcnow()

    if db_user:
        if db_user.is_verified:
            raise HTTPException(status_code=400, detail="Email already registered")
        else:
            # Update existing unverified user
            db_user.password_hash = hashed_password
            db_user.full_name = user.full_name
            db_user.phone_number = user.phone_number
            db_user.otp_code = otp
            db_user.otp_created_at = otp_created_at
            db.commit()
            background_tasks.add_task(mailer.send_otp_email, user.email, otp)
            return {"message": "User updated successfully. Please check your email for the new OTP."}

    new_user = models.User(
        email=user.email,
        password_hash=hashed_password,
        full_name=user.full_name,
        phone_number=user.phone_number,
        is_verified=False,
        otp_code=otp,
        otp_created_at=otp_created_at
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    background_tasks.add_task(mailer.send_otp_email, user.email, otp)

    return {"message": "User registered successfully. Please check your email for the OTP."}

@app.post("/bpa-register", response_model=dict)
async def bpa_register(user: schemas.BPARegisterRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    if not user.email.upper().startswith("BPA-"):
        raise HTTPException(status_code=400, detail="BPA Officer email must start with BPA-")

    clean_email = get_clean_email(user.email)
    db_user = db.query(models.User).filter(models.User.email == clean_email).first()
    
    hashed_password = security.get_password_hash(user.password)
    otp = utils.generate_otp()
    otp_created_at = datetime.utcnow()

    if db_user:
        if db_user.is_verified:
            raise HTTPException(status_code=400, detail="Email already registered")
        else:
            # Update existing unverified user
            db_user.password_hash = hashed_password
            db_user.full_name = user.full_name
            db_user.phone_number = user.phone_number
            db_user.otp_code = otp
            db_user.otp_created_at = otp_created_at
            db.commit()
            background_tasks.add_task(mailer.send_otp_email, clean_email, otp)
            return {"message": "BPA Officer updated successfully. Please check your email for the new OTP."}

    new_user = models.User(
        email=clean_email,
        password_hash=hashed_password,
        role="bpa",
        full_name=user.full_name,
        phone_number=user.phone_number,
        is_verified=False,
        otp_code=otp,
        otp_created_at=otp_created_at
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    background_tasks.add_task(mailer.send_otp_email, clean_email, otp)

    return {"message": "BPA Officer registered successfully. Please check your email for the OTP."}

@app.post("/verify-otp", response_model=dict)
def verify_otp(payload: schemas.OTPVerify, db: Session = Depends(get_db)):
    clean_email = get_clean_email(payload.email)
    db_user = db.query(models.User).filter(models.User.email == clean_email).first()

    if not db_user:
        raise HTTPException(status_code=404, detail="Email not registered")
        
    # Validation logic
    if db_user.otp_code != payload.otp_code:
        raise HTTPException(status_code=400, detail="Invalid OTP code")

    if not db_user.otp_created_at or datetime.utcnow() > db_user.otp_created_at + timedelta(minutes=10):
        # We allow a small grace period for network delays
        if datetime.utcnow() > db_user.otp_created_at + timedelta(minutes=12):
             raise HTTPException(status_code=400, detail="OTP code has expired")

    # Mark as verified and clear OTP
    db_user.is_verified = True
    db_user.otp_code = None
    db_user.otp_created_at = None

    db.commit()
    db.refresh(db_user)

    # Always generate token for both registration completion and password reset
    reset_token = security.create_access_token(
        data={"sub": db_user.email, "type": "reset"},
        expires_delta=timedelta(minutes=15)
    )

    return {"message": "Verification successful", "token": reset_token}

@app.post("/resend-otp")
async def resend_otp(payload: schemas.ForgotPassword, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_email = get_clean_email(payload.email)
    db_user = db.query(models.User).filter(models.User.email == clean_email).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Email not registered")
    otp = utils.generate_otp()
    db_user.otp_code = otp
    db_user.otp_created_at = datetime.utcnow()
    db.commit()
    background_tasks.add_task(mailer.send_otp_email, clean_email, otp)
    return {"message": "OTP resent successfully"}

@app.post("/forgot-password", response_model=dict)
async def forgot_password(payload: schemas.ForgotPassword, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_email = get_clean_email(payload.email)
    db_user = db.query(models.User).filter(models.User.email == clean_email).first()
    
    if not db_user or db_user.role != "farmer":
        raise HTTPException(status_code=404, detail="Email not registered")
        
    otp = utils.generate_otp()
    db_user.otp_code = otp
    db_user.otp_created_at = datetime.utcnow()
    db.commit()
    
    background_tasks.add_task(mailer.send_otp_email, clean_email, otp)
    return {"message": "Recovery OTP sent to email"}

@app.post("/bpa-forgot-password", response_model=dict)
async def bpa_forgot_password(payload: schemas.ForgotPassword, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    if not payload.email.upper().startswith("BPA-"):
        raise HTTPException(status_code=400, detail="Please enter BPA- prefix")
        
    clean_email = get_clean_email(payload.email)
    db_user = db.query(models.User).filter(models.User.email == clean_email).first()
    
    if not db_user or db_user.role != "bpa":
        raise HTTPException(status_code=404, detail="Email not registered")
        
    otp = utils.generate_otp()
    db_user.otp_code = otp
    db_user.otp_created_at = datetime.utcnow()
    db.commit()
    
    background_tasks.add_task(mailer.send_otp_email, clean_email, otp)
    return {"message": "Recovery OTP sent to email"}

@app.post("/reset-password", response_model=dict)
async def reset_password(payload: schemas.ResetPassword, db: Session = Depends(get_db)):
    try:
        token_payload = jwt.decode(payload.token, security.SECRET_KEY, algorithms=[security.ALGORITHM])
        email: str = token_payload.get("sub")
        if email is None:
            print(f"DEBUG Reset: Sub missing in token: {payload.token}")
            raise HTTPException(status_code=400, detail="Invalid token")
    except Exception as e:
        print(f"DEBUG Reset: JWT Decode failed: {e} | Token: {payload.token}")
        raise HTTPException(status_code=400, detail="Invalid or expired reset token")
        
    db_user = db.query(models.User).filter(models.User.email == email).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Email not registered")
        
    db_user.password_hash = security.get_password_hash(payload.new_password)
    db.commit()
    
    return {"message": "Password reset successful"}

@app.put("/users/me", response_model=schemas.UserResponse)
def update_profile(payload: schemas.UserUpdate, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    if payload.full_name:
        current_user.full_name = payload.full_name
    if payload.phone_number:
        current_user.phone_number = payload.phone_number
    if payload.profile_photo:
        current_user.profile_photo = payload.profile_photo
    db.commit()
    db.refresh(current_user)
    return current_user

@app.post("/users/me/photo", response_model=schemas.UserResponse)
async def upload_profile_photo(file: UploadFile = File(...), current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    os.makedirs("uploads/profiles", exist_ok=True)
    # Use a clean filename to avoid spaces / special chars
    ext = os.path.splitext(file.filename)[1] if file.filename else ".jpg"
    file_path = f"uploads/profiles/user_{current_user.id}{ext}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    current_user.profile_photo = file_path
    db.commit()
    db.refresh(current_user)
    return current_user

@app.post("/login", response_model=schemas.Token)
@app.post("/bpa-login", response_model=schemas.Token)
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    clean_email = get_clean_email(user.email)
    db_user = db.query(models.User).filter(models.User.email == clean_email).first()

    if not db_user:
        raise HTTPException(status_code=404, detail="Email not registered")

    if user.email.upper().startswith("BPA-") and db_user.role != "bpa":
        raise HTTPException(status_code=401, detail="Invalid password")
    if not user.email.upper().startswith("BPA-") and db_user.role != "farmer":
        raise HTTPException(status_code=401, detail="Invalid password")

    password_is_valid = False
    needs_hash_upgrade = False
    
    try:
        password_is_valid = security.verify_password(user.password, db_user.password_hash)
    except Exception:
        pass
        
    if not password_is_valid:
        if db_user.password_hash == user.password:
            password_is_valid = True
            needs_hash_upgrade = True
            
    if not password_is_valid:
        raise HTTPException(status_code=401, detail="Invalid password")
        
    if needs_hash_upgrade:
        db_user.password_hash = security.get_password_hash(user.password)
        db.commit()
        db.refresh(db_user)

    if not db_user.is_verified:
        raise HTTPException(status_code=403, detail="Account not verified. Please verify your OTP.")

    access_token_expires = timedelta(minutes=security.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = security.create_access_token(
        data={"sub": db_user.email, "id": db_user.id, "role": db_user.role}, 
        expires_delta=access_token_expires
    )

    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/me", response_model=schemas.UserResponse)
def get_me(current_user: models.User = Depends(security.get_current_user)):
    return current_user

@app.put("/me", response_model=schemas.UserResponse)
def update_me(payload: schemas.UserUpdate, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    if payload.full_name:
        current_user.full_name = payload.full_name
    if payload.phone_number:
        current_user.phone_number = payload.phone_number
    db.commit()
    db.refresh(current_user)
    return current_user

@app.delete("/account", response_model=dict)
def delete_account(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    db.delete(current_user)
    db.commit()
    return {"message": "Account successfully deleted"}

@app.get("/detections/me", response_model=List[schemas.DetectionResponse])
def get_my_detections(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    return db.query(models.AnimalDetection).filter(models.AnimalDetection.user_id == current_user.id).order_by(models.AnimalDetection.detected_at.desc()).all()

@app.post("/detections", response_model=schemas.DetectionResponse)
def save_manual_detection(detection: schemas.DetectionCreate, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    new_detection = models.AnimalDetection(
        user_id=current_user.id,
        breed_name=detection.breed_name,
        confidence_score=detection.confidence_score,
        yield_estimate=detection.yield_estimate,
        milk_yield_range=detection.milk_yield_range,
        animal_type=detection.animal_type,
        fat_content=detection.fat_content,
        image_path=detection.image_path,
        detected_at=datetime.utcnow()
    )
    db.add(new_detection)
    db.commit()
    db.refresh(new_detection)
    return new_detection

@app.get("/analytics", response_model=schemas.AnalyticsSummaryResponse)
def get_analytics(time_filter: str = "Week", current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    threshold_date = None
    if time_filter == "Week":
        threshold_date = datetime.now() - timedelta(days=7)
    elif time_filter == "15 Days":
        threshold_date = datetime.now() - timedelta(days=15)
    elif time_filter == "30 Days":
        threshold_date = datetime.now() - timedelta(days=30)

    if current_user.role == "bpa":
        base_query = db.query(models.RegisteredAnimal)
        if threshold_date:
            base_query = base_query.filter(models.RegisteredAnimal.registered_at >= threshold_date)
        # Merged activity for Growth Chart (Registrations + AI Scans)
        from sqlalchemy import union_all, literal_column
        
        det_query = db.query(func.date(models.AnimalDetection.detected_at).label('date'), literal_column('1').label('val'))
        if threshold_date:
            det_query = det_query.filter(models.AnimalDetection.detected_at >= threshold_date)
            
        reg_query = db.query(func.date(models.RegisteredAnimal.registered_at).label('date'), literal_column('1').label('val'))
        if threshold_date:
            reg_query = reg_query.filter(models.RegisteredAnimal.registered_at >= threshold_date)
            
        activity_union = det_query.union_all(reg_query).subquery()
        bar_results = db.query(activity_union.c.date, func.count().label('count')).group_by(activity_union.c.date).order_by(activity_union.c.date).all()
        
        # Padding logic for stock market style graph
        bar_dict = {str(row.date): row.count for row in bar_results if row.date}
        padded_bar_chart = []
        now = datetime.now()
        days_to_pad = 7
        if time_filter == "15 Days": days_to_pad = 15
        elif time_filter == "30 Days": days_to_pad = 30
        
        for i in range(days_to_pad - 1, -1, -1):
            d = (now - timedelta(days=i)).date()
            d_str = str(d)
            padded_bar_chart.append(schemas.BarChartData(date=d_str, value=bar_dict.get(d_str, 0)))
        bar_chart = padded_bar_chart
        
        # For BPA Pie Chart: Unique animals per breed across both
        all_reg = db.query(models.RegisteredAnimal.ear_tag_number, models.RegisteredAnimal.breed.label('breed')).all()
        all_det = db.query(models.AnimalDetection.animal_ear_tag, models.AnimalDetection.breed_name.label('breed')).filter(models.AnimalDetection.animal_ear_tag != None).all()
        
        # Breed -> Set of ear tags (to count unique animals per breed)
        breed_to_tags = {}
        for row in all_reg:
            if row.breed not in breed_to_tags: breed_to_tags[row.breed] = set()
            breed_to_tags[row.breed].add(row.ear_tag_number)
        for row in all_det:
            if row.breed not in breed_to_tags: breed_to_tags[row.breed] = set()
            breed_to_tags[row.breed].add(row.animal_ear_tag)
            
        pie_chart = [schemas.PieChartData(name=name, count=len(tags)) for name, tags in breed_to_tags.items()]
        
        # Total unique animals across all breeds
        total_animals = len(set().union(*breed_to_tags.values())) if breed_to_tags else 0
        total_scans = db.query(models.AnimalDetection).count()
        average_accuracy = 100.0
        # Avg yield for BPA: all detections
        avg_yield_val = db.query(func.avg(models.AnimalDetection.yield_estimate)).scalar() or 0.0
    else:
        # For Farmers: Count unique animals per breed
        # We consolidate by ear_tag_number to ensure correct percentages
        reg_animals = db.query(models.RegisteredAnimal.ear_tag_number, models.RegisteredAnimal.breed).filter(models.RegisteredAnimal.owner_name == current_user.full_name).all()
        det_animals = db.query(models.AnimalDetection.animal_ear_tag, models.AnimalDetection.breed_name).filter(models.AnimalDetection.user_id == current_user.id, models.AnimalDetection.animal_ear_tag != None).all()
        
        breed_to_tags = {}
        for row in reg_animals:
            if row.breed not in breed_to_tags: breed_to_tags[row.breed] = set()
            breed_to_tags[row.breed].add(row.ear_tag_number)
        for row in det_animals:
            if row.breed_name not in breed_to_tags: breed_to_tags[row.breed_name] = set()
            breed_to_tags[row.breed_name].add(row.animal_ear_tag)
            
        if not breed_to_tags:
            # Fallback to scan counts if no tagged animals found
            pie_results = db.query(models.AnimalDetection.breed_name.label('name'), func.count(models.AnimalDetection.id).label('count')).filter(models.AnimalDetection.user_id == current_user.id)
            if threshold_date:
                pie_results = pie_results.filter(models.AnimalDetection.detected_at >= threshold_date)
            pie_results = pie_results.group_by('name').all()
            pie_chart = [schemas.PieChartData(name=row.name, count=row.count) for row in pie_results]
            total_animals = sum(row.count for row in pie_results)
        else:
            pie_chart = [schemas.PieChartData(name=name, count=len(tags)) for name, tags in breed_to_tags.items()]
            total_animals = len(set().union(*breed_to_tags.values()))

        total_scans = db.query(models.AnimalDetection).filter(models.AnimalDetection.user_id == current_user.id).count()

        avg_acc_query = db.query(func.avg(models.AnimalDetection.confidence_score)).filter(models.AnimalDetection.user_id == current_user.id)
        if threshold_date:
            avg_acc_query = avg_acc_query.filter(models.AnimalDetection.detected_at >= threshold_date)
        average_accuracy = avg_acc_query.scalar() or 0.0
        
        # Avg yield for Farmer: their detections
        avg_yield_query = db.query(func.avg(models.AnimalDetection.yield_estimate)).filter(models.AnimalDetection.user_id == current_user.id)
        if threshold_date:
             avg_yield_query = avg_yield_query.filter(models.AnimalDetection.detected_at >= threshold_date)
        avg_yield_val = avg_yield_query.scalar() or 0.0

        # Bar results: Group by date and return SUM of yields for the overview (Total herd yield)
        bar_results = db.query(
            func.date(models.AnimalDetection.detected_at).label('date'), 
            func.count(models.AnimalDetection.id).label('count'), 
            func.sum(models.AnimalDetection.yield_estimate).label('total_yield')
        ).filter(models.AnimalDetection.user_id == current_user.id)
        if threshold_date:
            bar_results = bar_results.filter(models.AnimalDetection.detected_at >= threshold_date)
        bar_results = bar_results.group_by('date').order_by('date').all()
        
        # Padding logic
        bar_dict = {str(row.date): (row.count, row.total_yield) for row in bar_results}
        padded_bar_chart = []
        now = datetime.now()
        days_to_pad = 7
        if time_filter == "15 Days": days_to_pad = 15
        elif time_filter == "30 Days": days_to_pad = 30
        
        for i in range(days_to_pad - 1, -1, -1):
            d = (now - timedelta(days=i)).date()
            d_str = str(d)
            count, yield_val = bar_dict.get(d_str, (0, 0.0))
            padded_bar_chart.append(schemas.BarChartData(date=d_str, value=count, avg_yield=yield_val))
        bar_chart = padded_bar_chart

    return schemas.AnalyticsSummaryResponse(
        total_animals=total_animals, 
        total_scans=total_scans,
        average_accuracy=average_accuracy, 
        average_yield=avg_yield_val, 
        pie_chart=pie_chart, 
        bar_chart=bar_chart
    )

# --- AI Prediction (Proxy to AI Backend) ---

@app.post("/predict-animal")
async def predict_animal_local(
    file: UploadFile = File(...), 
    ear_tag: Optional[str] = fastapi.Form(None),
    current_user: models.User = Depends(security.get_current_user), 
    db: Session = Depends(get_db)
):
    try:
        # Create unique filename
        ext = os.path.splitext(file.filename)[1]
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"scan_{current_user.id}_{timestamp}{ext}"
        file_path = os.path.join(UPLOAD_DIR, filename)
        
        # Save uploaded file
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Run local YOLO prediction
        prediction = predict_breed(file_path)
        
        # Case 1: Model could not produce any result at all (runtime failure)
        if prediction is None:
            raise HTTPException(status_code=400, detail="Could not identify animal or breed in the image.")

        # Case 2: Image is not cattle or buffalo (low confidence or unknown class)
        if prediction.get("not_cattle"):
            return {
                "message": prediction.get("message", "DISCLAIMER: Image does not contain buffalo or cattle. Please upload another photo."),
                "image_url": file_path
            }
            
        # Case 3: Valid cattle/buffalo breed detected — save to database
        new_detection = models.AnimalDetection(
            user_id=current_user.id,
            breed_name=prediction["breed_name"],
            confidence_score=prediction["confidence_score"],
            yield_estimate=prediction["avg_yield"],
            milk_yield_range=prediction["milk_yield_range"],
            animal_type=prediction["animal_type"],
            fat_content=prediction["fat_content"],
            image_path=file_path,
            animal_ear_tag=ear_tag, # New field
            detected_at=datetime.utcnow()
        )
        db.add(new_detection)
        db.commit()
        db.refresh(new_detection)
        
        # Prepare response (matching frontend requirements)
        return {
            "breed_name": prediction["breed_name"],
            "confidence_score": prediction["confidence_score"],
            "milk_yield_range": prediction["milk_yield_range"],
            "yield_estimate": prediction["avg_yield"],
            "fat_content": prediction["fat_content"],
            "animal_type": prediction["animal_type"],
            "image_url": file_path,
            "id": new_detection.id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

# Keep old /predict endpoint for backward compatibility — delegates to predict_animal_local
@app.post("/predict")
async def predict_image(file: UploadFile = File(...), current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    return await predict_animal_local(file=file, ear_tag=None, current_user=current_user, db=db)

# --- BPA Animal Registration ---

@app.post("/register-animal", response_model=schemas.AnimalRegisterResponse)
def register_animal(animal: schemas.AnimalRegisterCreate, db: Session = Depends(get_db), current_user: models.User = Depends(security.get_current_user)):
    
    db_animal = db.query(models.RegisteredAnimal).filter(models.RegisteredAnimal.ear_tag_number == animal.ear_tag_number).first()
    if db_animal:
        raise HTTPException(status_code=400, detail="Animal with this Ear Tag Number already registered")
    
    new_animal = models.RegisteredAnimal(bpa_id=current_user.id, **animal.dict())
    db.add(new_animal)
    db.commit()
    db.refresh(new_animal)
    return new_animal

@app.get("/animals", response_model=List[schemas.AnimalRegisterResponse])
def get_animals(db: Session = Depends(get_db), current_user: models.User = Depends(security.get_current_user)):
    if current_user.role == "bpa":
        animals = db.query(models.RegisteredAnimal).all()
    else:
        # For farmers, filter by owner_name matching their full name
        animals = db.query(models.RegisteredAnimal).filter(
            (models.RegisteredAnimal.owner_name == current_user.full_name) | 
            (models.RegisteredAnimal.owner_name == current_user.email)
        ).all()
    results = []
    for animal in animals:
        latest_scan = db.query(models.AnimalDetection).filter(
            models.AnimalDetection.animal_ear_tag == animal.ear_tag_number
        ).order_by(models.AnimalDetection.detected_at.desc()).first()
        
        # Merge animal fields with last_image_path
        animal_data = {c.name: getattr(animal, c.name) for c in animal.__table__.columns}
        animal_data['last_image_path'] = latest_scan.image_path if latest_scan else None
        results.append(animal_data)
    return results

@app.get("/bpa/dashboard-stats", response_model=schemas.BPAStatsResponse)
def get_bpa_dashboard_stats(db: Session = Depends(get_db), current_user: models.User = Depends(security.get_current_user)):
    if current_user.role != "bpa":
        raise HTTPException(status_code=403, detail="Not authorized")
    total_animals = db.query(models.RegisteredAnimal).count()
    total_owners = db.query(models.RegisteredAnimal.owner_name).distinct().count()
    total_scans = db.query(models.AnimalDetection).count()
    ai_detections = db.query(models.AnimalDetection).filter(func.date(models.AnimalDetection.detected_at) == func.date(datetime.utcnow())).count()
    return {"total_animals": total_animals, "total_scans": total_scans, "total_owners": total_owners, "pending_verifications": 0, "ai_detections": ai_detections}

@app.get("/reports/summary", response_model=schemas.AnalyticsSummaryResponse)
async def get_report_summary(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    if current_user.role == "bpa":
        total_animals = db.query(models.RegisteredAnimal).count()
        total_scans = db.query(models.AnimalDetection).count()
        avg_accuracy = db.query(func.avg(models.AnimalDetection.confidence_score)).scalar() or 0.0
        pie_data = db.query(models.AnimalDetection.breed_name, func.count(models.AnimalDetection.id)).group_by(models.AnimalDetection.breed_name).all()
        bar_data = db.query(func.date(models.AnimalDetection.detected_at).label('date'), func.count(models.AnimalDetection.id).label('value'), func.avg(models.AnimalDetection.yield_estimate).label('avg_yield')).group_by(func.date(models.AnimalDetection.detected_at)).order_by('date').limit(7).all()
    else:
        total_animals = db.query(models.RegisteredAnimal).filter(models.RegisteredAnimal.owner_name == current_user.full_name).count()
        total_scans = db.query(models.AnimalDetection).filter(models.AnimalDetection.user_id == current_user.id).count()
        avg_accuracy = db.query(func.avg(models.AnimalDetection.confidence_score)).filter(models.AnimalDetection.user_id == current_user.id).scalar() or 0.0
        pie_data = db.query(models.AnimalDetection.breed_name, func.count(models.AnimalDetection.id)).filter(models.AnimalDetection.user_id == current_user.id).group_by(models.AnimalDetection.breed_name).all()
        bar_data = db.query(func.date(models.AnimalDetection.detected_at).label('date'), func.count(models.AnimalDetection.id).label('value'), func.avg(models.AnimalDetection.yield_estimate).label('avg_yield')).filter(models.AnimalDetection.user_id == current_user.id).group_by(func.date(models.AnimalDetection.detected_at)).order_by('date').limit(7).all()
    
    return {
        "total_animals": total_animals, 
        "total_scans": total_scans,
        "average_accuracy": avg_accuracy, 
        "pie_chart": [{"name": p[0], "count": p[1]} for p in pie_data], 
        "bar_chart": [{"date": str(b[0]), "value": b[1], "avg_yield": b[2]} for b in bar_data]
    }

@app.get("/activity/recent", response_model=List[schemas.RecentActivity])
def get_recent_activity(db: Session = Depends(get_db), current_user: models.User = Depends(security.get_current_user)):
    activities = []
    
    # Get detections for current user
    latest_detections = db.query(models.AnimalDetection)\
        .filter(models.AnimalDetection.user_id == current_user.id)\
        .order_by(models.AnimalDetection.detected_at.desc())\
        .limit(10).all()
        
    for det in latest_detections:
        activities.append(schemas.RecentActivity(
            id=f"scan_{det.id}",
            title="AI Scan Complete", 
            subtitle=f"{det.breed_name} ({int(det.confidence_score)}%)", 
            time=det.detected_at.isoformat(), 
            type="scan",
            breed_name=det.breed_name,
            confidence_score=det.confidence_score,
            image_path=det.image_path,
            detected_at=det.detected_at
        ))
    
    # If BPA, also show recent registrations (all, or just their own?)
    if current_user.role == "bpa":
        latest_regs = db.query(models.RegisteredAnimal)\
            .filter(models.RegisteredAnimal.bpa_id == current_user.id)\
            .order_by(models.RegisteredAnimal.registered_at.desc())\
            .limit(5).all()
            
        for reg in latest_regs:
            activities.append(schemas.RecentActivity(
                id=f"reg_{reg.id}",
                title="Animal Registered", 
                subtitle=f"{reg.breed} - {reg.owner_name}", 
                time=reg.registered_at.isoformat(), 
                type="registration"
            ))
            
    # Sort pooled activities by time if necessary, otherwise detections come first
    # For now, keeping detections at the top as requested
    return activities[:10]

# --- Notifications ---

@app.get("/notifications", response_model=List[schemas.NotificationResponse])
def get_notifications(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    return db.query(models.Notification).filter(models.Notification.user_id == current_user.id).order_by(models.Notification.created_at.desc()).all()

@app.put("/notifications/{notif_id}/read")
def mark_notification_read(notif_id: int, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    notif = db.query(models.Notification).filter(models.Notification.id == notif_id, models.Notification.user_id == current_user.id).first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    notif.is_read = True
    db.commit()
    return {"message": "Success"}

# --- Vaccination Schedule ---

@app.get("/vaccinations", response_model=List[schemas.VaccinationResponse])
def get_vaccinations(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    return db.query(models.VaccinationSchedule).filter(models.VaccinationSchedule.user_id == current_user.id).order_by(models.VaccinationSchedule.planned_date.asc()).all()

@app.post("/vaccinations", response_model=schemas.VaccinationResponse)
def create_vaccination(vaccine: schemas.VaccinationCreate, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    new_vax = models.VaccinationSchedule(
        user_id=current_user.id,
        **vaccine.dict()
    )
    db.add(new_vax)
    
    # Add a notification for the user
    new_notif = models.Notification(
        user_id=current_user.id,
        title="Vaccination Scheduled",
        message=f"A new vaccination for '{vaccine.vaccine_name}' has been scheduled for {vaccine.planned_date.strftime('%Y-%m-%d')}.",
        type="success"
    )
    db.add(new_notif)
    
    db.commit()
    db.refresh(new_vax)
    return new_vax

@app.put("/vaccinations/{vax_id}/complete", response_model=schemas.VaccinationResponse)
def complete_vaccination(vax_id: int, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    vax = db.query(models.VaccinationSchedule).filter(models.VaccinationSchedule.id == vax_id, models.VaccinationSchedule.user_id == current_user.id).first()
    if not vax:
        raise HTTPException(status_code=404, detail="Vaccination record not found")
    vax.status = "completed"
    vax.completion_date = datetime.utcnow()
    db.commit()
    db.refresh(vax)
    return vax

@app.get("/seasonal-reminders", response_model=List[schemas.SeasonalReminderResponse])
def get_seasonal_reminders(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    month = datetime.now().month
    if month in [3, 4, 5, 6]:
        season = "Summer"
        icon = "sun.max.fill"
    elif month in [7, 8, 9, 10]:
        season = "Monsoon"
        icon = "cloud.rain.fill"
    else:
        season = "Winter"
        icon = "snowflake"
        
    # Get breeds from registered animals
    user_breeds = db.query(models.RegisteredAnimal.breed).filter(models.RegisteredAnimal.bpa_id == current_user.id).distinct().all()
    # Also get from detections
    detected_breeds = db.query(models.AnimalDetection.breed_name).filter(models.AnimalDetection.user_id == current_user.id).distinct().all()
    
    breeds = set([b[0] for b in user_breeds] + [b[0] for b in detected_breeds])
    if not breeds:
        breeds = {"General Cattle"}
        
    results = []
    tips_map = {
        "Summer": ["Provide shade", "Install cooling systems", "Increase water supply", "Monitor heat stress"],
        "Monsoon": ["Ensure drainage", "Prevent moisture buildup", "Extra bedding", "Watch for hoof issues"],
        "Winter": ["Provide warm shelter", "Increase feed energy", "Check for drafts", "Maintain dry bedding"]
    }
    
    for breed in breeds:
        results.append(schemas.SeasonalReminderResponse(
            season=season,
            breed=breed,
            tips=tips_map[season],
            icon=icon
        ))
    return results

@app.get("/alerts", response_model=List[schemas.DiseaseAlertResponse])
def get_alerts(lat: Optional[float] = None, lon: Optional[float] = None, db: Session = Depends(get_db)):
    # Simple logic: Return alerts. In a production app, we would use lat/lon 
    # to filter alerts by distance or region.
    return db.query(models.DiseaseAlert).order_by(models.DiseaseAlert.created_at.desc()).all()

@app.delete("/vaccinations/{vax_id}")
def delete_vaccination(vax_id: int, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    vax = db.query(models.VaccinationSchedule).filter(models.VaccinationSchedule.id == vax_id, models.VaccinationSchedule.user_id == current_user.id).first()
    if not vax:
        raise HTTPException(status_code=404, detail="Vaccination record not found")
    db.delete(vax)
    db.commit()
    return {"message": "Deleted"}

# --- Milk Yield Tracking ---

@app.get("/milk-yields", response_model=List[schemas.MilkYieldResponse])
def get_milk_yields(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    return db.query(models.MilkYield).filter(models.MilkYield.user_id == current_user.id).order_by(models.MilkYield.recorded_at.desc()).all()

@app.post("/milk-yields", response_model=schemas.MilkYieldResponse)
def record_milk_yield(record: schemas.MilkYieldCreate, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    new_record = models.MilkYield(
        user_id=current_user.id,
        **record.dict()
    )
    db.add(new_record)
    db.commit()
    db.refresh(new_record)
    return new_record

# --- 21-Day Timetable ---

@app.get("/timetable", response_model=List[schemas.TimetableTaskResponse])
def get_timetable(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    return db.query(models.TimetableTask).filter(models.TimetableTask.user_id == current_user.id).order_by(models.TimetableTask.day_number.asc()).all()

@app.post("/timetable/generate")
def generate_timetable(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    # Delete existing timetable tasks if any (Reset Protocol)
    db.query(models.TimetableTask).filter(models.TimetableTask.user_id == current_user.id).delete()

        
    tasks = [
        {"day": 1, "title": "Breed Selection Check", "desc": "Review the best breeds for your local climate and water availability."},
        {"day": 2, "title": "Feed Optimization", "desc": "Balance the ratio of green fodder and dry fodder based on animal weight."},
        {"day": 3, "title": "Watering Routine", "desc": "Ensure animals have access to clean, mineral-rich water at least 3 times a day."},
        {"day": 4, "title": "Health Inspection", "desc": "Check eyes, muzzle, and coat for any signs of early infection or pests."},
        {"day": 5, "title": "Shed Sanitation", "desc": "Thoroughly clean the shed floor and ensure proper ventilation."},
        # Simplified for brevity, usually would go to 21
    ]
    
    # Fill up to 21 days for demonstration
    for day in range(1, 22):
        task_info = next((t for t in tasks if t["day"] == day), {"day": day, "title": f"Routine Maintenance Day {day}", "desc": "Continue standard care procedures and record daily yield."})
        new_task = models.TimetableTask(
            user_id=current_user.id,
            day_number=day,
            title=task_info["title"],
            description=task_info["desc"],
            scheduled_for=datetime.utcnow() + timedelta(days=day-1)
        )
        db.add(new_task)
    
    db.commit()
    return {"message": "Timetable generated successfully for 21 days"}

@app.put("/timetable/{task_id}/complete")
def complete_task(task_id: int, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    task = db.query(models.TimetableTask).filter(models.TimetableTask.id == task_id, models.TimetableTask.user_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    task.is_completed = not task.is_completed
    db.commit()
    status_str = "completed" if task.is_completed else "reset to pending"
    return {"message": f"Task {status_str}"}

@app.get("/bpa-stats", response_model=schemas.BPAStatsResponse)
def get_bpa_stats(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "bpa":
        raise HTTPException(status_code=403, detail="Forbidden")
    
    # Combined unique animals (by ear tag) across both detections and registrations
    reg_tags = db.query(models.RegisteredAnimal.ear_tag_number).distinct().all()
    det_tags = db.query(models.AnimalDetection.animal_ear_tag).filter(models.AnimalDetection.animal_ear_tag != None).distinct().all()
    
    unique_tags = set([t[0] for t in reg_tags] + [t[0] for t in det_tags])
    total_animals = len(unique_tags)
    
    total_owners = db.query(models.RegisteredAnimal.owner_name).distinct().count()
    
    # Pending verification if animal_name is missing OR no AI scan (AnimalDetection) exists for the tag
    scanned_tags = db.query(models.AnimalDetection.animal_ear_tag).filter(models.AnimalDetection.animal_ear_tag != None).distinct().subquery()
    pending_verifications = db.query(models.RegisteredAnimal).filter(
        or_(
            models.RegisteredAnimal.animal_name == None,
            models.RegisteredAnimal.animal_name == "",
            ~models.RegisteredAnimal.ear_tag_number.in_(scanned_tags)
        )
    ).count()
    
    # AI Detections today
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    ai_detections_today = db.query(models.AnimalDetection).filter(models.AnimalDetection.detected_at >= today_start).count()
    total_scans = db.query(models.AnimalDetection).count()
    
    return {
        "total_animals": total_animals,
        "total_scans": total_scans,
        "total_owners": total_owners,
        "pending_verifications": pending_verifications,
        "ai_detections": ai_detections_today
    }

@app.get("/farmers", response_model=List[schemas.UserResponse])
def get_farmers(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "bpa":
        raise HTTPException(status_code=403, detail="Forbidden")
    return db.query(models.User).filter(models.User.role == "farmer").all()

@app.get("/detections", response_model=List[schemas.DetectionResponse])
def get_all_detections(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "bpa":
        raise HTTPException(status_code=403, detail="Forbidden")
    return db.query(models.AnimalDetection).order_by(models.AnimalDetection.detected_at.desc()).all()

@app.get("/animals/{ear_tag}/history", response_model=List[schemas.DetectionResponse])
def get_animal_history(ear_tag: str, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    return db.query(models.AnimalDetection).filter(models.AnimalDetection.animal_ear_tag == ear_tag).order_by(models.AnimalDetection.detected_at.desc()).all()

# --- Animal & Detection Management ---

@app.put("/animals/{animal_id}", response_model=schemas.AnimalRegisterResponse)
def update_animal(animal_id: int, payload: schemas.AnimalRegisterCreate, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "bpa":
        raise HTTPException(status_code=403, detail="Only BPA officers can update animals")
    
    db_animal = db.query(models.RegisteredAnimal).filter(models.RegisteredAnimal.id == animal_id).first()
    if not db_animal:
        raise HTTPException(status_code=404, detail="Animal not found")
    
    for key, value in payload.dict().items():
        setattr(db_animal, key, value)
    
    db.commit()
    db.refresh(db_animal)
    return db_animal

@app.delete("/detections/{detection_id}")
def delete_detection(detection_id: int, current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    detection = db.query(models.AnimalDetection).filter(models.AnimalDetection.id == detection_id, models.AnimalDetection.user_id == current_user.id).first()
    if not detection:
        raise HTTPException(status_code=404, detail="Detection not found")
    
    db.delete(detection)
    db.commit()
    return {"message": "Detection deleted"}

@app.get("/reports/export")
def export_report(current_user: models.User = Depends(security.get_current_user)):
    # Simulated PDF export link/metadata
    return {
        "report_id": f"REP-{datetime.now().strftime('%Y%m%d%H%M')}",
        "url": "https://example.com/reports/sample.pdf",
        "generated_at": datetime.utcnow()
    }

@app.delete("/account")
def delete_account(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    db.delete(current_user)
    db.commit()
    return {"message": "Account deleted successfully"}



