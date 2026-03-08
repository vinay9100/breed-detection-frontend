from sqlalchemy import text
from database import engine

import traceback

try:
    with engine.connect() as con:
        # Add role column if it doesn't exist
        try:
            con.execute(text("ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'farmer';"))
            print("Added 'role' column to users table.")
        except Exception as e:
            print("Role column might already exist:", e)
        
        try:
            con.execute(text("DROP TABLE IF EXISTS bpa_users;"))
            print("Dropped bpa_users table.")
        except Exception as e:
            print("bpa_users table might not exist:", e)

        # Add animal_type and fat_content to animal_detections
        try:
            con.execute(text("ALTER TABLE animal_detections ADD COLUMN animal_type VARCHAR(50);"))
            print("Added 'animal_type' column to animal_detections.")
        except Exception as e:
            print("animal_type column might already exist:", e)
            
        try:
            con.execute(text("ALTER TABLE animal_detections ADD COLUMN fat_content VARCHAR(50);"))
            print("Added 'fat_content' column to animal_detections.")
        except Exception as e:
            print("fat_content column might already exist:", e)

        con.commit()
except Exception as e:
    print("Database migration error:")
    traceback.print_exc()
