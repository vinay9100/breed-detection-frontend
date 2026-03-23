from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, ForeignKey
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), default="farmer")
    full_name = Column(String(100), nullable=False)
    phone_number = Column(String(20), nullable=True)
    profile_photo = Column(String(255), nullable=True)
    
    # OTP Verification Fields
    is_verified = Column(Boolean, default=False)
    otp_code = Column(String(6), nullable=True)
    otp_created_at = Column(DateTime, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    detections = relationship("AnimalDetection", back_populates="user", cascade="all, delete-orphan")

class AnimalDetection(Base):
    __tablename__ = "animal_detections"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    breed_name = Column(String(100), nullable=False, index=True) # E.g., Holstein, Jersey
    confidence_score = Column(Float, nullable=False) # E.g., 95.5
    yield_estimate = Column(Float, nullable=True) # numeric estimate for analytics
    milk_yield_range = Column(String(100), nullable=True) # E.g., 16-20 Liters/day
    animal_type = Column(String(50), nullable=True)
    fat_content = Column(String(50), nullable=True)
    image_path = Column(String(255), nullable=True)
    animal_ear_tag = Column(String(50), nullable=True, index=True) # Tag scan to registered animal
    detected_at = Column(DateTime, default=datetime.utcnow, index=True)
    
    # Relationships
    user = relationship("User", back_populates="detections")

class RegisteredAnimal(Base):
    __tablename__ = "registered_animals"
    
    id = Column(Integer, primary_key=True, index=True)
    bpa_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    # Animal Info
    animal_name = Column(String(100), nullable=True)
    ear_tag_number = Column(String(50), unique=True, index=True, nullable=False)
    species = Column(String(50), nullable=False)
    sex = Column(String(20), nullable=False)
    breed = Column(String(100), nullable=False)
    dob = Column(String(20), nullable=True) # Stored as string DD/MM/YYYY
    
    # Owner Info
    owner_name = Column(String(100), nullable=False)
    address = Column(String(255), nullable=True)
    village = Column(String(100), nullable=False)
    district = Column(String(100), nullable=False)
    state = Column(String(100), nullable=False)
    
    registered_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship to BPA Officer (User)
    officer = relationship("User")

class Notification(Base):
    __tablename__ = "notifications"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(String(1000), nullable=False)
    type = Column(String(50), default="info") # info, warning, success
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User")

class VaccinationSchedule(Base):
    __tablename__ = "vaccination_schedules"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    animal_id = Column(Integer, ForeignKey("registered_animals.id", ondelete="CASCADE"), nullable=True) # Optional link to specific animal
    vaccine_name = Column(String(255), nullable=False)
    type = Column(String(100), nullable=True) # E.g., Annual, Bi-annual
    planned_date = Column(DateTime, nullable=False)
    completion_date = Column(DateTime, nullable=True)
    status = Column(String(50), default="scheduled") # scheduled, completed, overdue
    
    user = relationship("User")
    animal = relationship("RegisteredAnimal")

class MilkYield(Base):
    __tablename__ = "milk_yields"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    animal_id = Column(Integer, ForeignKey("registered_animals.id", ondelete="CASCADE"), nullable=True)
    yield_amount = Column(Float, nullable=False) # In liters
    fat_content = Column(Float, nullable=True) # %
    recorded_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User")
    animal = relationship("RegisteredAnimal")

class TimetableTask(Base):
    __tablename__ = "timetable_tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    day_number = Column(Integer, nullable=False) # 1 to 21
    title = Column(String(255), nullable=False)
    description = Column(String(1000), nullable=True)
    is_completed = Column(Boolean, default=False)
    scheduled_for = Column(DateTime, nullable=False)
    
    user = relationship("User")

class DiseaseAlert(Base):
    __tablename__ = "disease_alerts"
    
    id = Column(Integer, primary_key=True, index=True)
    disease_name = Column(String(255), nullable=False)
    message = Column(String(1000), nullable=False)
    location = Column(String(255), nullable=False) # e.g., Chennai
    severity = Column(String(50), nullable=False, default="High") # High, Medium, Low
    created_at = Column(DateTime, default=datetime.utcnow)
