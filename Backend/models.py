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
    yield_estimate = Column(Float, nullable=True) # Estimated milk yield based on analytics
    animal_type = Column(String(50), nullable=True)
    fat_content = Column(String(50), nullable=True)
    detected_at = Column(DateTime, default=datetime.utcnow, index=True)
    
    # Relationships
    user = relationship("User", back_populates="detections")

class RegisteredAnimal(Base):
    __tablename__ = "registered_animals"
    
    id = Column(Integer, primary_key=True, index=True)
    bpa_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    # Animal Info
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
