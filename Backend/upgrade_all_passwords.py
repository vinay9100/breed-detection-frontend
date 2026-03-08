from sqlalchemy.orm import sessionmaker
import models, main, security

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=main.engine)
db = SessionLocal()

users = db.query(models.User).all()

count = 0
for u in users:
    # bcrypt hashes start with $2a$, $2b$, or $2y$ and are typically 60 chars long.
    # We can just check if it doesn't look like a bcrypt hash.
    if not u.password_hash.startswith("$2b$"):
        print(f"Upgrading plaintext password for user ID={u.id} (Email={u.email})")
        u.password_hash = security.get_password_hash(u.password_hash)
        count += 1

db.commit()
print(f"Successfully upgraded {count} existing plaintext passwords to securely hashed bcrypt strings.")
