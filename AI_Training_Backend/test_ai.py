import requests
import os

# Your backend URL
URL = "http://127.0.0.1:8001/predict"

# Use the image name shown in your VS Code explorer
image_path = "test.jpg"

def run_test():
    if not os.path.exists(image_path):
        print(f"Error: Could not find '{image_path}' in the current folder.")
        return

    print(f"Testing AI with image: {image_path}...")
    
    with open(image_path, "rb") as f:
        files = {"file": (image_path, f, "image/jpeg")}
        response = requests.post(URL, files=files)
        
    if response.status_code == 200:
        result = response.json()
        print("\n--- AI Results ---")
        if result.get("not_cattle"):
            print(f"Outcome: {result['message']}")
        else:
            print(f"Breed Detected: {result['breed_name']}")
            print(f"Confidence: {result['confidence_score']:.2f}%")
            print(f"Type: {result['animal_type']}")
            print(f"Typical Yield: {result['milk_yield_range']}")
            print(f"Fat Content: {result['fat_content']}")
        print("------------------\n")
    else:
        print(f"Server Error: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    run_test()