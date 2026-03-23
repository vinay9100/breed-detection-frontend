import pymysql
import os
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USER", "root")
DB_PASS = os.getenv("DB_PASS", "")
DB_NAME = os.getenv("DB_NAME", "bsai")

def seed_alerts():
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        
        with connection.cursor() as cursor:
            # Create table if not exists (redundant since FastAPI does it, but good for script)
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS disease_alerts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                disease_name VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                location VARCHAR(255) NOT NULL,
                severity VARCHAR(50) NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
            """)
            
            # Check if already seeded
            cursor.execute("SELECT COUNT(*) as count FROM disease_alerts")
            if cursor.fetchone()['count'] == 0:
                alerts = [
                    ("Foot and Mouth Disease", "FMD outbreak detected nearby. Vaccinate cattle immediately.", "Chennai", "High"),
                    ("Lumpy Skin Disease", "Cases reported in your district. Monitor livestock for skin nodules.", "Hyderabad", "Medium"),
                    ("Vaccination Drive", "BPA conducting free FMD vaccination drive at your nearest center tomorrow.", "Karnal", "Medium")
                ]
                
                sql = "INSERT INTO disease_alerts (disease_name, message, location, severity) VALUES (%s, %s, %s, %s)"
                cursor.executemany(sql, alerts)
                print(f"Seeded {len(alerts)} alerts.")
            else:
                print("Alerts already seeded.")
                
        connection.commit()
        connection.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    seed_alerts()
