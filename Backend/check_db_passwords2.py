from sqlalchemy.orm import sessionmaker
import models, main

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=main.engine)
db = SessionLocal()

users = db.query(models.User).all()
for u in users:
    print(f"ID={u.id}, Email={u.email}, Role={u.role}, Verified={u.is_verified}, PasswordHash={u.password_hash}")
