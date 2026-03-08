import requests
import json
from datetime import datetime

base_url = "http://127.0.0.1:8000"

def test_analytics():
    email = "testanalytics@example.com"
    password = "testpassword123"
    
    # 1. Register User
    print("Registering analyst user...")
    register_data = {"email": email, "password": password, "full_name": "Test Analyst", "phone_number": "123"}
    requests.post(f"{base_url}/register", json=register_data)
    
    # Verify User
    import sys
    sys.path.append('.')
    from database import engine
    from sqlalchemy import text
    with engine.connect() as conn:
        conn.execute(text(f"UPDATE users SET is_verified = 1 WHERE email = '{email}'"))
        conn.commit()
        
    # Login
    print("Logging in...")
    req = requests.post(f"{base_url}/login", json=register_data)
    token = req.json().get("access_token")
    headers = {"Authorization": f"Bearer {token}"}
    
    # 2. Add Detections
    print("Adding 3 Holstein and 2 Jersey records...")
    detections = [
        {"breed_name": "Holstein", "confidence_score": 98.5, "yield_estimate": 25.0},
        {"breed_name": "Holstein", "confidence_score": 94.0, "yield_estimate": 22.0},
        {"breed_name": "Holstein", "confidence_score": 99.1, "yield_estimate": 28.0},
        {"breed_name": "Jersey", "confidence_score": 88.5, "yield_estimate": 15.0},
        {"breed_name": "Jersey", "confidence_score": 91.2, "yield_estimate": 16.5},
    ]
    
    for d in detections:
        res = requests.post(f"{base_url}/detections", json=d, headers=headers)
        if res.status_code != 200:
            print("Failed to add detection:", res.text)
            
    # 3. Fetch Analytics
    print("Fetching Analytics calculations...")
    res = requests.get(f"{base_url}/analytics?time_filter=Week", headers=headers)
    print("Analytics Code:", res.status_code)
    try:
        data = res.json()
        print(json.dumps(data, indent=2))
    except:
        print(res.text)

if __name__ == "__main__":
    test_analytics()
