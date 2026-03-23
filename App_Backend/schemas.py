from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone_number: Optional[str] = None

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    profile_photo: Optional[str] = None

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

class ForgotPassword(BaseModel):
    email: EmailStr

class ResetPassword(BaseModel):
    token: str
    new_password: str

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
    profile_photo: Optional[str] = None
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True

# --- Analytics \u0026 Detections ---

class PredictResponse(BaseModel):
    breed_name: str
    confidence_score: float
    milk_yield_range: str
    animal_type: str
    fat_content: str
    image_url: str

class DetectionCreate(BaseModel):
    breed_name: str
    confidence_score: float
    yield_estimate: Optional[float] = None
    milk_yield_range: Optional[str] = None
    animal_type: Optional[str] = None
    fat_content: Optional[str] = None
    image_path: Optional[str] = None

class DetectionResponse(BaseModel):
    id: int
    user_id: int
    breed_name: str
    confidence_score: float
    yield_estimate: Optional[float] = None
    milk_yield_range: Optional[str] = None
    animal_type: Optional[str] = None
    fat_content: Optional[str] = None
    image_path: Optional[str] = None
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
    average_yield: Optional[float] = 0.0
    pie_chart: List[PieChartData]
    bar_chart: List[BarChartData]

# --- BPA Animal Registration ---

class AnimalRegisterCreate(BaseModel):
    ear_tag_number: str
    animal_name: Optional[str] = None
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
    last_image_path: Optional[str] = None

    class Config:
        from_attributes = True

class RecentActivity(BaseModel):
    id: str
    title: str
    subtitle: str
    time: str
    type: str  # 'scan' or 'registration'
    breed_name: Optional[str] = None
    confidence_score: Optional[float] = None
    image_path: Optional[str] = None
    detected_at: Optional[datetime] = None

class BPAStatsResponse(BaseModel):
    total_animals: int
    total_owners: int
    pending_verifications: int
    ai_detections: int

# --- New Modules ---

class NotificationResponse(BaseModel):
    id: int
    title: str
    message: str
    type: str
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True

class VaccinationCreate(BaseModel):
    animal_id: Optional[int] = None
    vaccine_name: str
    type: Optional[str] = None
    planned_date: datetime

class VaccinationResponse(VaccinationCreate):
    id: int
    user_id: int
    status: str
    completion_date: Optional[datetime] = None

    class Config:
        from_attributes = True

class MilkYieldCreate(BaseModel):
    animal_id: Optional[int] = None
    yield_amount: float
    fat_content: Optional[float] = None

class MilkYieldResponse(MilkYieldCreate):
    id: int
    recorded_at: datetime

    class Config:
        from_attributes = True

class TimetableTaskResponse(BaseModel):
    id: int
    day_number: int
    title: str
    description: Optional[str] = None
    is_completed: bool
    scheduled_for: datetime

    class Config:
        from_attributes = True

class DiseaseAlertResponse(BaseModel):
    id: int
    disease_name: str
    message: str
    location: str
    severity: str
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class SeasonalReminderResponse(BaseModel):
    season: str
    breed: str
    tips: List[str]
    icon: str
