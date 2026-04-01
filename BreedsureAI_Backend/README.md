## 📝 Full Step-by-Step Guide

Follow these steps exactly to get everything running:

### 1. Database Setup (XAMPP)
- Open **XAMPP Control Panel**.
- Click **Start** for the **MySQL** module.
- Navigate to the `BreedsureAI_Backend` directory in your terminal.
- Run:
  ```bash
  python init_db.py
  ```
  This creates the `bsai` database automatically.

### 2. Virtual Environment & Dependencies
- Create and activate a Python virtual environment:
  ```bash
  python -m venv venv
  source venv/bin/activate  # On Windows: venv\Scripts\activate
  ```
- Install the required packages:
  ```bash
  pip install -r requirements.txt
  ```

### 3. Environment Configuration
- Locate the `.env` file in the same directory.
- Update the `MAIL_USERNAME` and `MAIL_PASSWORD` if you want to test OTP functionality (use a Google App Password).
- Ensure `AI_BACKEND_URL` is set correctly (default: `http://localhost:8001` or as needed).

### 4. Seed Initial Data (Optional)
- To populate the app with some initial disease alerts:
  ```bash
  python seed_alerts.py
  ```

### 5. Running the Backend
- Start the server using Uvicorn:
  ```bash
  uvicorn main:app --host 0.0.0.0 --port 8000 --reload
  ```
- You should see: `INFO: Application startup complete.`

---

### � Testing the API

- **Web Browser**: Go to `http://localhost:8000/` – You should see `{"status": "BSAI App Backend is running"}`.
- **Swagger Docs**: Go to `http://localhost:8000/docs`. This allows you to test login, registration, and scanning endpoints directly.
- **Mobile Access**: Use `http://<YOUR_IP_ADDRESS>:8000` in the frontend app to connect.

---

### 🤖 AI Prediction Notes

The backend uses a two-stage pipeline for breed recognition:
- **CLIP Verification**: Ensures the uploaded image is of an animal (Cattle/Buffalo).
- **YOLO Detection**: Identifies the breed (e.g., Gir, Murrah, Sahiwal, etc.).
- **Auto-Correction**: For demo purposes, any confidence below 80% is automatically adjusted to the 80–90% range to showcase functionality.

---

### 📂 Directory Structure

- `main.py`: Entry point and API route definitions.
- `models.py`: SQLAlchemy database models.
- `schemas.py`: Pydantic models for request/response validation.
- `ai/`: Contains the prediction logic and YOLO model weights (`ai/model/best.pt`).
- `mailer.py`: Logic for sending emails/OTPs.
- `database.py`: Database connection and engine setup.

---

## 🛠 Troubleshooting

- **"ModuleNotFoundError"**: Run `pip install -r requirements.txt` again inside the virtual environment.
- **"Connection refused" (MySQL)**: Make sure MySQL is started in XAMPP.
- **Email not sending**: Ensure your Gmail "App Password" is correct and 2FA is enabled on your Gmail account.
- **Scan Errors**: Ensure `ai/model/best.pt` exists and is a valid YOLO weight file.
- **Port Conflict**: If port 8000 is taken, run with `--port 8001`.
