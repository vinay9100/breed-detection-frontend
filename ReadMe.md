# BSAI Infrastructure Guide

The project has been organized into logical sections for Backend, Frontend, and Web services to ensure a clean development environment.

---

### 📂 Directory Structure
- **`backend/api/`**: Core API for user management, authentication (OTP), and reporting.
- **`backend/ai-service/`**: AI Service for breed detection (YOLO) and model training.
- **`frontend/ios/`**: Native iOS application for farmers and field agents.
- **`web/landing-page/`**: High-end landing page and web dashboard.
- **`scripts/`**: Internal tools for localization, translation, and system maintenance.

---

### 🚀 How to Run

#### 1. AI Training Backend (Port 8001)
*Handles all heavy AI computations.*
```bash
cd backend/ai-service
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8001
```

#### 2. App Backend (Port 8000)
*Main gateway for the App. It communicates with the AI Backend automatically.*
```bash
cd backend/api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

#### 3. Web Frontend (Port 5174)
*High-end React dashboard for Farmers and BPA Officers.*
```bash
cd web/landing-page
npm install
npm run dev
```

#### 4. IOS Frontend
*SwiftUI based mobile application.*
- Open `frontend/ios/BSAI.xcodeproj` in Xcode.
- Select your target device and run.

---

### 🛠 Configuration
- The **App Backend** is configured via `.env` in `backend/api/`. 
- It uses `AI_BACKEND_URL=http://localhost:8001` to send images for scanning.
- Detection results are stored in the local SQLite database automatically.

### 🧠 AI Training
To trigger a new training cycle after updating your dataset:
- Use the `POST /train` endpoint on the AI Backend (Port 8001).
- Training progress can be tracked at `GET /train/status`.

