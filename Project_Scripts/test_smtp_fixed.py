import asyncio
import aiosmtplib
import ssl
import certifi
import os
from dotenv import load_dotenv
from email.message import EmailMessage

# This is the path the user has open
dotenv_path = "/Users/vinay/Downloads/BSAI/Backend/.env"
load_dotenv(dotenv_path)

async def test_smtp_fixed():
    server = os.getenv("MAIL_SERVER")
    port = os.getenv("MAIL_PORT", "587")
    user = os.getenv("MAIL_USERNAME")
    password = os.getenv("MAIL_PASSWORD")
    
    print(f"Testing with: {server}:{port} as {user}")
    
    message = EmailMessage()
    message["From"] = user
    message["To"] = user
    message["Subject"] = "BSAI SMTP Test (Fixed SSL)"
    message.set_content("This is a diagnostic test for SSL validation.")
    
    # Create an SSL context using certifi's certificates
    context = ssl.create_default_context(cafile=certifi.where())
    
    try:
        await aiosmtplib.send(
            message,
            hostname=server,
            port=int(port),
            username=user,
            password=password,
            use_tls=False,
            start_tls=True,
            tls_context=context # Explicitly provide the context
        )
        print("SUCCESS: Connection and authentication successful!")
    except Exception as e:
        print(f"FAILED: {type(e).__name__}: {e}")

if __name__ == "__main__":
    asyncio.run(test_smtp_fixed())
