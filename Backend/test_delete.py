import requests

base_url = "http://127.0.0.1:8000"

def test_delete_account():
    # 1. Register a test user
    email = "testdelete@example.com"
    password = "testpassword123"
    
    register_data = {
        "email": email,
        "password": password,
        "full_name": "Test Delete User",
        "phone_number": "1234567890"
    }
    
    print("Registering test user...")
    req = requests.post(f"{base_url}/register", json=register_data)
    print("Register Status:", req.status_code)
    
    # User needs to be verified before login. Let's do a direct DB update to bypass OTP check.
    import sys
    sys.path.append('.')
    from database import engine
    from sqlalchemy import text
    with engine.connect() as conn:
        conn.execute(text(f"UPDATE users SET is_verified = 1 WHERE email = '{email}'"))
        conn.commit()
    print("User verified in DB.")
        
    print("Logging in...")
    login_data = {
        "email": email,
        "password": password
    }
    req = requests.post(f"{base_url}/login", json=login_data)
    print("Login Status:", req.status_code)
    
    if req.status_code == 200:
        token = req.json().get("access_token")
        
        print("Deleting account...")
        headers = {"Authorization": f"Bearer {token}"}
        req = requests.delete(f"{base_url}/account", headers=headers)
        print("Delete Status:", req.status_code)
        print("Delete Response:", req.text)
        
        # Verify user is gone
        req = requests.post(f"{base_url}/login", json=login_data)
        print("Login Status after deletion:", req.status_code)
        if req.status_code == 401 or req.status_code == 404:
            print("SUCCESS! User was deleted.")
        else:
            print("FAILURE! User still exists.")
    else:
        print("Failed to login.")
        print(req.text)

if __name__ == "__main__":
    test_delete_account()
