# BSAI Infrastructure Guide

The project has been segregated into two independent backend services to ensure performance and scalability.

---

### 📂 Directory Structure
- **`App_Backend/`**: Core API for user management, authentication (OTP), and reporting.
- **`AI_Training_Backend/`**: AI Service for breed detection (YOLO) and model training.
- **`Project_Scripts/`**: Internal tools for localization, translation, and database cleanup.
- **`Logs/`**: Build and error logs.

---

### 🚀 How to Run

#### 1. AI Training Backend (Port 8001)
*Handles all heavy AI computations.*
```bash
cd AI_Training_Backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8001
```

#### 2. App Backend (Port 8000)
*Main gateway for the App. It communicates with the AI Backend automatically.*
```bash
cd App_Backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

#### 3. Web Frontend (Port 5174)
*High-end React dashboard for Farmers and BPA Officers.*
```bash
cd bsai-web-front
npm install
npm run dev
```

---

### 🛠 Configuration
- The **App Backend** is configured via `.env`. 
- It uses `AI_BACKEND_URL=http://localhost:8001` to send images for scanning.
- Detection results are stored in the local SQLite database automatically.

### 🧠 AI Training
To trigger a new training cycle after updating your dataset:
- Use the `POST /train` endpoint on the AI Backend (Port 8001).
- Training progress can be tracked at `GET /train/status`.
