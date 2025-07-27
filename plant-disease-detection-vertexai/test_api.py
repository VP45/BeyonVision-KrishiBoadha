#!/usr/bin/env python3
"""
Simple test script for the Plant Disease Detection API
"""

import requests
import json
import sys
import os

API_BASE_URL = "http://localhost:8080"

def test_health_check():
    """Test the health check endpoint"""
    print("Testing health check...")
    try:
        response = requests.get(f"{API_BASE_URL}/health")
        if response.status_code == 200:
            print("✅ Health check passed")
            print(f"Response: {response.json()}")
            return True
        else:
            print(f"❌ Health check failed with status {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Health check failed: {e}")
        return False

def test_api_info():
    """Test the API info endpoint"""
    print("\nTesting API info...")
    try:
        response = requests.get(f"{API_BASE_URL}/")
        if response.status_code == 200:
            print("✅ API info endpoint working")
            print(f"Response: {json.dumps(response.json(), indent=2)}")
            return True
        else:
            print(f"❌ API info failed with status {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ API info failed: {e}")
        return False

def test_predict_no_file():
    """Test the predict endpoint without a file"""
    print("\nTesting predict endpoint without file...")
    try:
        response = requests.post(f"{API_BASE_URL}/predict")
        if response.status_code == 400:
            print("✅ Correctly rejected request without file")
            print(f"Response: {response.json()}")
            return True
        else:
            print(f"❌ Unexpected status code {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Test failed: {e}")
        return False

def test_predict_with_file(image_path):
    """Test the predict endpoint with an image file"""
    if not os.path.exists(image_path):
        print(f"❌ Test image not found: {image_path}")
        return False
        
    print(f"\nTesting predict endpoint with image: {image_path}")
    try:
        with open(image_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{API_BASE_URL}/predict", files=files)
            
        if response.status_code == 200:
            print("✅ Prediction successful")
            result = response.json()
            print(f"Response: {json.dumps(result, indent=2)}")
            return True
        else:
            print(f"❌ Prediction failed with status {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Test failed: {e}")
        return False

def main():
    print("Plant Disease Detection API Test Suite")
    print("=" * 50)
    
    # Test basic endpoints
    health_ok = test_health_check()
    info_ok = test_api_info()
    no_file_ok = test_predict_no_file()
    
    # Test with image file if provided
    image_test_ok = True
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
        image_test_ok = test_predict_with_file(image_path)
    else:
        print("\nSkipping image prediction test (no image file provided)")
        print("Usage: python test_api.py [path_to_test_image]")
    
    # Summary
    print("\n" + "=" * 50)
    print("Test Summary:")
    print(f"Health Check: {'✅' if health_ok else '❌'}")
    print(f"API Info: {'✅' if info_ok else '❌'}")
    print(f"No File Validation: {'✅' if no_file_ok else '❌'}")
    if len(sys.argv) > 1:
        print(f"Image Prediction: {'✅' if image_test_ok else '❌'}")
    
    if all([health_ok, info_ok, no_file_ok, image_test_ok]):
        print("\n🎉 All tests passed!")
        return 0
    else:
        print("\n❌ Some tests failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())
