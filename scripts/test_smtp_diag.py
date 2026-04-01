import asyncio
import aiosmtplib
import os
from dotenv import load_dotenv
from email.message import EmailMessage

# Adjust path to match the actual folder name
dotenv_path = os.path.join(os.getcwd(), "Backend", ".env")
load_dotenv(dotenv_path)

async def test_smtp():
    server = os.getenv("MAIL_SERVER")
    port = os.getenv("MAIL_PORT")
    user = os.getenv("MAIL_USERNAME")
    password = os.getenv("MAIL_PASSWORD")
    
    print(f"Testing with: {server}:{port} as {user}")
    
    message = EmailMessage()
    message["From"] = user
    message["To"] = user # Send to self
    message["Subject"] = "BSAI SMTP Test"
    message.set_content("This is a test email from the BSAI backend diagnostic script.")
    
    try:
        await aiosmtplib.send(
            message,
            hostname=server,
            port=int(port),
            username=user,
            password=password,
            use_tls=False,
            start_tls=True
        )
        print("SUCCESS: Connection and authentication successful!")
    except Exception as e:
        print(f"FAILED: {type(e).__name__}: {e}")

if __name__ == "__main__":
    asyncio.run(test_smtp())
