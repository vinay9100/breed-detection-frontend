#!/bin/bash
# Move to the project root
cd "/Users/sail/Downloads/BSAI 2/App_Backend"

# Create venv if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment for App Backend..."
    python3 -m venv venv
fi

# Activate and install
source venv/bin/activate
pip install -r requirements.txt

# Start the server
echo "Starting App Backend on http://localhost:8000..."
uvicorn main:app --reload --port 8000
