from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import engine, Base, get_db
import models, schemas, utils, security, mailer
from datetime import datetime, timedelta
from typing import List, Optional
import os
import shutil

# AI Integrations
try:
    from ultralytics import YOLO
    MODEL_PATH = "models_ai/best.pt"
    if os.path.exists(MODEL_PATH):
        yolo_model = YOLO(MODEL_PATH)
    else:
        yolo_model = None
        print("Warning: YOLO model not found at", MODEL_PATH)
except ImportError:
    yolo_model = None
    print("Warning: ultralytics not installed")

# Breed Data for ML mapping
BREED_INFO = {
    "Holstein_Friesian": {"Type": "Cow", "Milk": 24.5, "Fat": "3.2-4.0%"},
    "Jersey":            {"Type": "Cow", "Milk": 18.0, "Fat": "4.5-6.0%"},
    "Brown_Swiss":       {"Type": "Cow", "Milk": 22.0, "Fat": "4.0-4.5%"},
    "Gir":               {"Type": "Cow", "Milk": 14.0, "Fat": "4.5-5.5%"},
    "Sahiwal":           {"Type": "Cow", "Milk": 16.0, "Fat": "4.5-5.5%"},
    "Murrah":            {"Type": "Buffalo", "Milk": 16.0, "Fat": "6.0-8.0%"},
    "Jaffrabadi":        {"Type": "Buffalo", "Milk": 14.0, "Fat": "6.5-8.5%"},
    "Pandharpuri":       {"Type": "Buffalo", "Milk": 8.0,  "Fat": "6.0-7.0%"},
    "Toda":              {"Type": "Buffalo", "Milk": 4.0,  "Fat": "8.0-12.0%"},
}

# Create database tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="BSAI Backend API")

@app.get("/")
def read_root():
    return {"status": "BSAI API is running"}

@app.post("/register", response_model=dict)
async def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Hash password
    hashed_password = security.get_password_hash(user.password)

    # Generate OTP
    otp = utils.generate_otp()
    otp_created_at = datetime.utcnow()

    # Create user in DB
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

    # Send OTP Email
    try:
        await mailer.send_otp_email(user.email, otp)
    except Exception as e:
        import traceback
        print(f"CRITICAL Error sending email: {e}")
        traceback.print_exc()
        # In production we might handle this better, but for now we won't block registration

    return {"message": "User registered successfully. Please check your email for the OTP."}

@app.post("/bpa-register", response_model=dict)
async def bpa_register(user: schemas.BPARegisterRequest, db: Session = Depends(get_db)):
    if not user.email.upper().startswith("BPA-"):
        raise HTTPException(status_code=400, detail="BPA Officer email must start with BPA-")

    db_user_email = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user_email:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Hash password
    hashed_password = security.get_password_hash(user.password)

    # Generate OTP
    otp = utils.generate_otp()
    otp_created_at = datetime.utcnow()

    # Create BPA user in DB
    new_user = models.User(
        email=user.email,
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

    # Send OTP Email
    try:
        await mailer.send_otp_email(user.email, otp)
    except Exception as e:
        import traceback
        print(f"CRITICAL Error sending email: {e}")
        traceback.print_exc()

    return {"message": "BPA Officer registered successfully. Please check your email for the OTP."}

@app.post("/verify-otp", response_model=dict)
def verify_otp(payload: schemas.OTPVerify, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == payload.email).first()
    
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
        
    if db_user.is_verified:
        return {"message": "Email is already verified"}

    if db_user.otp_code != payload.otp_code:
        raise HTTPException(status_code=400, detail="Invalid OTP code")

    # Check if OTP expired (10 minutes)
    if not db_user.otp_created_at or datetime.utcnow() > db_user.otp_created_at + timedelta(minutes=10):
        raise HTTPException(status_code=400, detail="OTP code has expired")

    # Verification successful
    db_user.is_verified = True
    db_user.otp_code = None 
    db_user.otp_created_at = None
    db.commit()

    return {"message": "Email verified successfully"}

@app.post("/login", response_model=schemas.Token)
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    
    if not db_user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
        
    # Check if the database has a valid bcrypt hash, or if it's a legacy/manually inserted plaintext password
    password_is_valid = False
    needs_hash_upgrade = False
    
    try:
        # Try to verify via bcrypt first
        password_is_valid = security.verify_password(user.password, db_user.password_hash)
    except Exception:
        # If passlib throws an error (e.g. invalid hash format), it might be plaintext
        pass
        
    if not password_is_valid:
        # Check if they match exactly in plaintext
        if db_user.password_hash == user.password:
            password_is_valid = True
            needs_hash_upgrade = True
            
    if not password_is_valid:
        raise HTTPException(status_code=401, detail="Invalid credentials")
        
    # Automatic hash upgrade for plaintext passwords
    if needs_hash_upgrade:
        db_user.password_hash = security.get_password_hash(user.password)
        db.commit()
        db.refresh(db_user)

    if not db_user.is_verified:
        # If the user is manually created by the admin, they might not be verified. 
        # Alternatively, we can let them verify via OTP.
        raise HTTPException(status_code=403, detail="Account not verified. Please verify your OTP.")

    # Create JWT
    access_token_expires = timedelta(minutes=security.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = security.create_access_token(
        data={"sub": db_user.email, "id": db_user.id, "role": db_user.role}, 
        expires_delta=access_token_expires
    )


    return {"access_token": access_token, "token_type": "bearer"}

@app.delete("/account", response_model=dict)
def delete_account(current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    db.delete(current_user)
    db.commit()
    return {"message": "Account successfully deleted"}

@app.get("/detections/me", response_model=List[schemas.DetectionResponse])
def get_my_detections(
    current_user: models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(models.AnimalDetection).filter(models.AnimalDetection.user_id == current_user.id).order_by(models.AnimalDetection.detected_at.desc()).all()

# --- Analytics \u0026 Reports ---

@app.post("/detections", response_model=schemas.DetectionResponse)
def create_detection(
    detection: schemas.DetectionCreate,
    current_user: models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    new_detection = models.AnimalDetection(
        user_id=current_user.id,
        breed_name=detection.breed_name,
        confidence_score=detection.confidence_score,
        yield_estimate=detection.yield_estimate
    )
    db.add(new_detection)
    db.commit()
    db.refresh(new_detection)
    return new_detection

@app.get("/analytics", response_model=schemas.AnalyticsSummaryResponse)
def get_analytics(
    time_filter: str = "Week",  # 'Week', '15 Days', '30 Days', 'All'
    current_user: models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    # Determine date threshold based on time_filter
    threshold_date = None
    if time_filter == "Week":
        threshold_date = datetime.now() - timedelta(days=7)
    elif time_filter == "15 Days":
        threshold_date = datetime.now() - timedelta(days=15)
    elif time_filter == "30 Days":
        threshold_date = datetime.now() - timedelta(days=30)

    if current_user.role == "bpa":
        # BPA Analytics (from RegisteredAnimal table)
        base_query = db.query(models.RegisteredAnimal)
        if threshold_date:
            base_query = base_query.filter(models.RegisteredAnimal.registered_at >= threshold_date)
            
        # 1. Total Animals
        total_animals = base_query.count()
        
        # 2. Average Accuracy (BPA returns 100 for registered units)
        average_accuracy = 100.0
        
        # 3. Pie Chart (Group by breed)
        pie_results = db.query(
            models.RegisteredAnimal.breed.label('name'),
            func.count(models.RegisteredAnimal.id).label('count')
        )
        if threshold_date:
            pie_results = pie_results.filter(models.RegisteredAnimal.registered_at >= threshold_date)
        pie_results = pie_results.group_by('name').all()
        pie_chart = [schemas.PieChartData(name=row.name, count=row.count) for row in pie_results]
        
        # 4. Bar Chart (Group by Date)
        bar_results = db.query(
            func.date(models.RegisteredAnimal.registered_at).label('date'),
            func.count(models.RegisteredAnimal.id).label('count')
        )
        if threshold_date:
            bar_results = bar_results.filter(models.RegisteredAnimal.registered_at >= threshold_date)
        bar_results = bar_results.group_by('date').order_by('date').all()
        bar_chart = [schemas.BarChartData(date=str(row.date), value=row.count) for row in bar_results]
        
    else:
        # Farmer Analytics (from AnimalDetection table)
        base_query = db.query(models.AnimalDetection).filter(models.AnimalDetection.user_id == current_user.id)
        if threshold_date:
            base_query = base_query.filter(models.AnimalDetection.detected_at >= threshold_date)
            
        # 1. Total Animals
        total_animals = base_query.count()
        
        # 2. Average Accuracy
        avg_acc_query = db.query(func.avg(models.AnimalDetection.confidence_score)).filter(models.AnimalDetection.user_id == current_user.id)
        if threshold_date:
            avg_acc_query = avg_acc_query.filter(models.AnimalDetection.detected_at >= threshold_date)
        average_accuracy = avg_acc_query.scalar() or 0.0
        
        # 3. Pie Chart (Group by breed)
        pie_results = db.query(
            models.AnimalDetection.breed_name.label('name'),
            func.count(models.AnimalDetection.id).label('count')
        ).filter(models.AnimalDetection.user_id == current_user.id)
        if threshold_date:
            pie_results = pie_results.filter(models.AnimalDetection.detected_at >= threshold_date)
        pie_results = pie_results.group_by('name').all()
        pie_chart = [schemas.PieChartData(name=row.name, count=row.count) for row in pie_results]
        
        # 4. Bar Chart (Group by Date + Avg Yield)
        bar_results = db.query(
            func.date(models.AnimalDetection.detected_at).label('date'),
            func.count(models.AnimalDetection.id).label('count'),
            func.avg(models.AnimalDetection.yield_estimate).label('avg_yield')
        ).filter(models.AnimalDetection.user_id == current_user.id)
        if threshold_date:
            bar_results = bar_results.filter(models.AnimalDetection.detected_at >= threshold_date)
        bar_results = bar_results.group_by('date').order_by('date').all()
        bar_chart = [schemas.BarChartData(date=str(row.date), value=row.count, avg_yield=row.avg_yield) for row in bar_results]

    return schemas.AnalyticsSummaryResponse(
        total_animals=total_animals,
        average_accuracy=average_accuracy,
        pie_chart=pie_chart,
        bar_chart=bar_chart
    )

# --- AI Prediction ---

@app.post("/predict", response_model=schemas.PredictResponse)
def predict_image(file: UploadFile = File(...), current_user: models.User = Depends(security.get_current_user), db: Session = Depends(get_db)):
    if not yolo_model:
        raise HTTPException(status_code=503, detail="AI Model is not loaded on the server.")
        
    try:
        # Save temp file
        temp_file = f"temp_{file.filename}"
        with open(temp_file, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Run inference
        results = yolo_model(temp_file)
        
        if len(results) == 0:
            os.remove(temp_file)
            raise HTTPException(status_code=400, detail="Could not analyze image.")
            
        r = results[0]
        top_index = r.probs.top1
        breed_name = r.names[top_index]
        confidence = r.probs.top1conf.item() * 100 # percentage
        
        info = BREED_INFO.get(breed_name, {"Type": "Unknown", "Milk": 0.0, "Fat": "N/A"})
        
        os.remove(temp_file)
        
        # Replace underscores for readability
        clean_breed_name = breed_name.replace("_", " ")
        
        # Save detection to database
        new_detection = models.AnimalDetection(
            user_id=current_user.id,
            breed_name=clean_breed_name,
            confidence_score=confidence,
            yield_estimate=info["Milk"],
            animal_type=info["Type"],
            fat_content=info["Fat"]
        )
        db.add(new_detection)
        db.commit()
        
        return schemas.PredictResponse(
            breed_name=clean_breed_name,
            confidence_score=confidence,
            yield_estimate=info["Milk"],
            animal_type=info["Type"],
            fat_content=info["Fat"]
        )
        
    except Exception as e:
        if os.path.exists(temp_file):
            os.remove(temp_file)
        raise HTTPException(status_code=500, detail=str(e))

# --- BPA Animal Registration ---

@app.post("/register-animal", response_model=schemas.AnimalRegisterResponse)
def register_animal(
    animal: schemas.AnimalRegisterCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    # Ensure only BPA officers can register animals
    if current_user.role != "bpa":
        raise HTTPException(status_code=403, detail="Only BPA officers can register animals")
    
    # Check if ear tag already exists
    db_animal = db.query(models.RegisteredAnimal).filter(models.RegisteredAnimal.ear_tag_number == animal.ear_tag_number).first()
    if db_animal:
        raise HTTPException(status_code=400, detail="Animal with this Ear Tag Number already registered")
    
    new_animal = models.RegisteredAnimal(
        bpa_id=current_user.id,
        **animal.dict()
    )
    
    db.add(new_animal)
    db.commit()
    db.refresh(new_animal)
    return new_animal

@app.get("/animals", response_model=List[schemas.AnimalRegisterResponse])
def get_animals(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    # Allow both farmers and BPA to see lists
    return db.query(models.RegisteredAnimal).all()

@app.get("/bpa/dashboard-stats", response_model=schemas.BPAStatsResponse)
def get_bpa_dashboard_stats(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    if current_user.role != "bpa":
        raise HTTPException(status_code=403, detail="Not authorized")
        
    total_animals = db.query(models.RegisteredAnimal).count()
    total_owners = db.query(models.RegisteredAnimal.owner_name).distinct().count()
    ai_detections = db.query(models.AnimalDetection).count()
    
    return {
        "total_animals": total_animals,
        "total_owners": total_owners,
        "pending_verifications": 0,  # Could be expanded with a verification status field
        "ai_detections": ai_detections
    }

@app.get("/reports/summary", response_model=schemas.AnalyticsSummaryResponse)
async def get_report_summary(
    current_user: models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    # Reuse analytics logic for report summary
    # total animals, avg accuracy, pie_chart, bar_chart
    total_animals = db.query(models.AnimalDetection).filter(models.AnimalDetection.user_id == current_user.id).count()
    
    avg_accuracy = db.query(func.avg(models.AnimalDetection.confidence_score)).filter(
        models.AnimalDetection.user_id == current_user.id
    ).scalar() or 0.0

    # Pie Chart
    pie_data = db.query(
        models.AnimalDetection.breed_name,
        func.count(models.AnimalDetection.id)
    ).filter(models.AnimalDetection.user_id == current_user.id).group_by(models.AnimalDetection.breed_name).all()
    
    # Bar Chart (Last 7 days)
    bar_data = db.query(
        func.date(models.AnimalDetection.detected_at).label('date'),
        func.count(models.AnimalDetection.id).label('value'),
        func.avg(models.AnimalDetection.yield_estimate).label('avg_yield')
    ).filter(models.AnimalDetection.user_id == current_user.id).group_by(func.date(models.AnimalDetection.detected_at)).order_by('date').limit(7).all()

    return {
        "total_animals": total_animals,
        "average_accuracy": avg_accuracy,
        "pie_chart": [{"name": p[0], "count": p[1]} for p in pie_data],
        "bar_chart": [{"date": str(b[0]), "value": b[1], "avg_yield": b[2]} for b in bar_data]
    }

@app.get("/activity/recent", response_model=List[schemas.RecentActivity])
def get_recent_activity(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(security.get_current_user)
):
    activities = []
    
    # Get latest registrations
    latest_regs = db.query(models.RegisteredAnimal).order_by(models.RegisteredAnimal.registered_at.desc()).limit(5).all()
    for reg in latest_regs:
        activities.append(schemas.RecentActivity(
            title="Animal Registered",
            subtitle=f"{reg.breed} - {reg.owner_name}",
            time=reg.registered_at.strftime("%H:%M %p"),
            type="registration"
        ))
        
    # Get latest detections
    latest_detections = db.query(models.AnimalDetection).order_by(models.AnimalDetection.detected_at.desc()).limit(5).all()
    for det in latest_detections:
        activities.append(schemas.RecentActivity(
            title="AI Scan Complete",
            subtitle=f"{det.breed_name} ({int(det.confidence_score)}%)",
            time=det.detected_at.strftime("%H:%M %p"),
            type="scan"
        ))
        
    # Sort combined activities by time (simplified since we don't have full precision here, but good enough)
    # Ideally should include date for sorting, but for 'recent' we can just return these.
    return activities[:10]
