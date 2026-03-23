import random

def generate_otp() -> str:
    """Generates a secure 6-digit OTP"""
    return str(random.randint(100000, 999999))