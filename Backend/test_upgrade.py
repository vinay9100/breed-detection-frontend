from sqlalchemy.orm import sessionmaker
import models, main
from fastapi.testclient import TestClient

client = TestClient(main.app)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=main.engine)
db = SessionLocal()

# Ensure we have a dummy user with plaintext password in DB
test_email = "plaintext_bpa@gmail.com"
existing = db.query(models.User).filter(models.User.email == test_email).first()
if existing:
    db.delete(existing)
    db.commit()

user = models.User(
    email=test_email,
    password_hash="MyPlaintextPassword123!",
    role="bpa",
    full_name="Plaintext User",
    is_verified=True # Bypassing OTP for this specific test
)
db.add(user)
db.commit()
print("Inserted dummy plaintext user into database.")

# Now try to log in
login_payload = {
    "email": test_email,
    "password": "MyPlaintextPassword123!"
}
res = client.post("/login", json=login_payload)
print("Login Result:", res.status_code, res.json())

# Check the DB again
db.refresh(user)
print("Updated password hash in DB:", user.password_hash)
print("Is it upgraded?", user.password_hash != "MyPlaintextPassword123!")
