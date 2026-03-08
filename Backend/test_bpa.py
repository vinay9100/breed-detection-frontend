from sqlalchemy.orm import sessionmaker
import models, schemas, main
from fastapi.testclient import TestClient

client = TestClient(main.app)

def test_bpa_register_and_login():
    email = "BPA-TESTER99@gmail.com"
    payload = {
        "email": email,
        "password": "SecurePassword123!",
        "full_name": "Test Officer Modified",
        "phone_number": "1234567890"
    }
    
    response = client.post("/bpa-register", json=payload)
    print("Register Response:", response.status_code, response.json())
    
    # Try logging in
    login_payload = {
        "email": email,
        "password": "SecurePassword123!"
    }
    
    login_res = client.post("/login", json=login_payload)
    print("Login Response:", login_res.status_code)
    
    if login_res.status_code == 403: # Account not verified
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=main.engine)
        db = SessionLocal()
        bpa_user = db.query(models.User).filter(models.User.email == email).first()
        bpa_user.is_verified = True
        db.commit()
        db.refresh(bpa_user)
        print("BPA User manually verified.")
        
        # Try logging in again
        login_res2 = client.post("/login", json=login_payload)
        print("Login 2 Response:", login_res2.status_code)
        
        if login_res2.status_code == 200:
            import jwt
            token = login_res2.json().get("access_token")
            # Decode JWT without verifying signature
            payload = jwt.decode(token, options={"verify_signature": False})
            print("Token Payload:", payload)
            if payload.get("role") == "bpa":
                print("SUCCESS: Role is correctly set to bpa.")
            else:
                print("ERROR: Role is incorrect:", payload.get("role"))

if __name__ == "__main__":
    test_bpa_register_and_login()
