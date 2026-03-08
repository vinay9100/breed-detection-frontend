import sys
import os

# Add parent directory to path for imports
sys.path.append(os.path.join(os.getcwd(), "Backend"))

try:
    from database import SessionLocal
    import models
except ImportError:
    print("Error: Could not import backend modules. Run this from the root BSAI directory.")
    sys.exit(1)

def purge_mock_data():
    db = SessionLocal()
    try:
        print("Purging all animal detections...")
        db.query(models.AnimalDetection).delete()
        
        print("Purging all registered animals...")
        db.query(models.RegisteredAnimal).delete()
        
        # Optionally keep users but clear their specific data
        # We don't want to delete the BPA officers or Farmers themselves unless specified.
        
        db.commit()
        print("Successfully purged all mock/test data records.")
    except Exception as e:
        db.rollback()
        print(f"Error purging data: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    confirm = input("Are you sure you want to delete ALL scans and registrations? (y/N): ")
    if confirm.lower() == 'y':
        purge_mock_data()
    else:
        print("Purge cancelled.")
