#!/bin/bash
# Master Run Script for BSAI Project

echo "Welcome to BreedSureAI (BSAI) Launch Manager"
echo "-------------------------------------------"
echo "1. Run AI Backend (Port 8001)"
echo "2. Run App Backend (Port 8000)"
echo "3. Run Web Landing Page (Port 5174)"
echo "4. Exit"
echo ""
read -p "Select an option: " choice

case $choice in
    1)
        bash scripts/run_ai.sh
        ;;
    2)
        bash scripts/run_app.sh
        ;;
    3)
        cd web/landing-page && npm install && npm run dev
        ;;
    4)
        exit 0
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
