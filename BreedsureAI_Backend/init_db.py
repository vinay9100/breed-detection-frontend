import pymysql

def create_db():
    try:
        # Connect without specific database
        connection = pymysql.connect(
            host='localhost',
            user='root',
            password=''
        )
        cursor = connection.cursor()
        cursor.execute("CREATE DATABASE IF NOT EXISTS bsai")
        print("Database 'bsai' checked/created successfully.")
        connection.close()
    except Exception as e:
        print(f"Error creating database: {e}")
        print("Make sure XAMPP MySQL is STARTING in the XAMPP Control Panel.")

if __name__ == "__main__":
    create_db()
