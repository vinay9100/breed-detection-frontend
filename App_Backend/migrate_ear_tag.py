import pymysql

def migrate():
    try:
        connection = pymysql.connect(
            host='localhost',
            user='root',
            password='',
            database='bsai'
        )
        cursor = connection.cursor()
        
        # Check if the column exists
        cursor.execute("SHOW COLUMNS FROM animal_detections LIKE 'animal_ear_tag'")
        result = cursor.fetchone()
        
        if not result:
            print("Adding animal_ear_tag column to animal_detections table...")
            cursor.execute("ALTER TABLE animal_detections ADD COLUMN animal_ear_tag VARCHAR(50) DEFAULT NULL")
            cursor.execute("CREATE INDEX ix_animal_detections_animal_ear_tag ON animal_detections(animal_ear_tag)")
            connection.commit()
            print("Success: Column animal_ear_tag added.")
        else:
            print("Column animal_ear_tag already exists.")
            
        connection.close()
    except Exception as e:
        print(f"Error during migration: {e}")

if __name__ == "__main__":
    migrate()
