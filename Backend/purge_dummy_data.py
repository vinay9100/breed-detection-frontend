from database import SessionLocal
import models

def purge_data():
    db = SessionLocal()
    try:
        print("Purging dummy data...")
        
        # Delete all records from RegisteredAnimal (BPA role data)
        num_registered = db.query(models.RegisteredAnimal).delete()
        print(f"Deleted {num_registered} registered animals.")
        
        # Delete all records from AnimalDetection (Farmer role data)
        num_detections = db.query(models.AnimalDetection).delete()
        print(f"Deleted {num_detections} animal detections.")
        
        db.commit()
        print("Successfully purged all dummy data from both roles.")
    except Exception as e:
        db.rollback()
        print(f"Error purging data: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    purge_data()
