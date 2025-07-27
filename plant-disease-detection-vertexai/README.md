# Plant Disease Detection Flask Application

This repository contains a Flask web application for detecting plant diseases from uploaded images. It integrates with Google Cloud Storage and Vertex AI to process images and generate predictions.

## Features

- **Image Upload:** Users can upload images of plant leaves through a user-friendly web interface.
- **Cloud Integration:** Images are uploaded to Google Cloud Storage for processing.
- **AI-powered Prediction:** Uses Vertex AI's GenerativeModel to identify plant diseases and provide remediation steps.

---

## Documentation

Meduim Link : [[Plant Disease Detection](https://medium.com/@vandavasi.manoj/building-a-plant-disease-detection-web-app-with-flask-vertex-ai-and-google-cloud-0ffc6bae422d)]


## Live Demo
The live application can be tested out in this URL: [[Link](https://plant-disease-detection-268625998399.us-central1.run.app/)]

  
## Run Locally

## Prerequisites

### Tools & Setup
- **Python** (Version 3.10 or higher)
- **Google Cloud Platform (GCP)**:
  - **Google Cloud Storage** bucket for storing uploaded images.
  - **Vertex AI** for processing images and generating predictions.

### Configuration Files
- **Service Account JSON Keys**:
  - `gcp_storage.json` for authenticating with Google Cloud Storage, you can download this from Cloud console IAM.
  - `plant-disease-vertex-api.json` for authenticating with Vertex AI,this needs to be created, you can download this from Cloud console IAM.
- Place gcp_storage.json and plant-disease-vertex-api.json in the root folder.
- Ensure the Google Cloud Storage bucket is configured, and replace bucket_name in app.py with your actual bucket name.

### Step 1: Clone the Repository
```bash
git clone https://github.com/krishna-manoj96/plant-disease-detection-vertexai
cd plant-disease-detection-vertexai
```

### Step 2: Setup Environemnt
```bash
pip install requirements.txt
```

### Step 3 : Run Locally
```bash
python app.py
```

## Output Reference
#### Upload.html 
![image](https://github.com/user-attachments/assets/e4c0ca33-bc2c-4a05-ae72-a5d9b6d71ee2)

#### result.html

![image](https://github.com/user-attachments/assets/94d3c75a-d07d-4d73-ac57-7c3d5cc8b4b2)




