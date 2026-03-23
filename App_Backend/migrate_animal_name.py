import pymysql
import os
from dotenv import load_dotenv

load_dotenv()

# MySQL connection
try:
    conn = pymysql.connect(
        host="localhost",
        user="root",
        password="",
        database="bsai",
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    cursor = conn.cursor()

    # Add animal_name to registered_animals table
    try:
        cursor.execute("ALTER TABLE registered_animals ADD COLUMN animal_name VARCHAR(100) AFTER bpa_id")
        conn.commit()
        print("Column animal_name added to registered_animals.")
    except Exception as e:
        if "Duplicate column name" in str(e):
            print("Column animal_name already exists in registered_animals.")
        else:
            print(f"Error adding column: {e}")

    conn.close()
except Exception as e:
    print(f"Error connecting to database: {e}")
