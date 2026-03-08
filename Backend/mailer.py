from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from pydantic import EmailStr
import os
from dotenv import load_dotenv

load_dotenv()

conf = ConnectionConfig(
    MAIL_USERNAME = os.getenv("MAIL_USERNAME"),
    MAIL_PASSWORD = os.getenv("MAIL_PASSWORD"),
    MAIL_FROM = os.getenv("MAIL_FROM"),
    MAIL_PORT = int(os.getenv("MAIL_PORT", 587)),
    MAIL_SERVER = os.getenv("MAIL_SERVER"),
    MAIL_STARTTLS = True,
    MAIL_SSL_TLS = False,
    USE_CREDENTIALS = True,
    VALIDATE_CERTS = False
)

async def send_otp_email(email: EmailStr, otp: str):
    html = f"""
    <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
        <h2>BreedSure AI</h2>
        <p>Your verification code is:</p>
        <h1 style="color: #00A661; letter-spacing: 5px;">{otp}</h1>
        <p>This code will expire in 10 minutes.</p>
    </div>
    """

    message = MessageSchema(
        subject="Your BSAI Verification Code",
        recipients=[email],
        body=html,
        subtype=MessageType.html
    )

    fm = FastMail(conf)
    await fm.send_message(message)
