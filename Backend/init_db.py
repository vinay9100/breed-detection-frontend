from database import engine
import models

print("Creating new database tables if missing...")
models.Base.metadata.create_all(bind=engine)
print("Done!")
