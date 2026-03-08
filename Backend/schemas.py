from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone_number: Optional[str] = None

class BPARegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone_number: Optional[str] = None

class OTPVerify(BaseModel):
    email: EmailStr
    otp_code: str

class UserLogin(BaseModel):
    email: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    full_name: str
    phone_number: Optional[str] = None
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True

# --- Analytics \u0026 Detections ---

class PredictResponse(BaseModel):
    breed_name: str
    confidence_score: float
    yield_estimate: Optional[float] = None
    animal_type: str
    fat_content: str

class DetectionCreate(BaseModel):
    breed_name: str
    confidence_score: float
    yield_estimate: Optional[float] = None

class DetectionResponse(DetectionCreate):
    id: int
    user_id: int
    animal_type: str
    fat_content: str
    detected_at: datetime

    class Config:
        from_attributes = True

class PieChartData(BaseModel):
    name: str # Breed name
    count: int

class BarChartData(BaseModel):
    date: str # Formatted grouping date, e.g., 'Mon' or 'Jan 01'
    value: int # Count of detections on that date
    avg_yield: Optional[float] = None

class AnalyticsSummaryResponse(BaseModel):
    total_animals: int
    average_accuracy: float
    pie_chart: List[PieChartData]
    bar_chart: List[BarChartData]

# --- BPA Animal Registration ---

class AnimalRegisterCreate(BaseModel):
    ear_tag_number: str
    species: str
    sex: str
    breed: str
    dob: Optional[str] = None
    owner_name: str
    address: Optional[str] = None
    village: str
    district: str
    state: str

class AnimalRegisterResponse(AnimalRegisterCreate):
    id: int
    bpa_id: int
    registered_at: datetime

    class Config:
        from_attributes = True

class RecentActivity(BaseModel):
    title: str
    subtitle: str
    time: str
    type: str  # 'scan' or 'registration'

class BPAStatsResponse(BaseModel):
    total_animals: int
    total_owners: int
    pending_verifications: int
    ai_detections: int
