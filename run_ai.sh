#!/bin/bash
# Move to the project root
cd "/Users/sail/Downloads/BSAI 2/AI_Training_Backend"

# Create venv if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment for AI Backend..."
    python3 -m venv venv
fi

# Activate and install
source venv/bin/activate
pip install -r requirements.txt

# Start the server
echo "Starting AI Backend on http://localhost:8001..."
uvicorn main:app --reload --port 8001
