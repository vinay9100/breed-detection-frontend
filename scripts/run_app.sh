#!/bin/bash
# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"

# Move to the App Backend directory
cd "$PROJECT_ROOT/BreedsureAI_Backend"


# Create venv if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment for App Backend..."
    python3 -m venv venv
fi

# Activate and install
source venv/bin/activate
pip install -r requirements.txt

# Start the server on 0.0.0.0 for cross-device access
echo "Starting App Backend on http://0.0.0.0:8000..."
uvicorn main:app --reload --host 0.0.0.0 --port 8000

