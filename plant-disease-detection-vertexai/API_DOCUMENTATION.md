# Plant Disease Detection REST API

## Overview
This API provides plant disease detection using Google Vertex AI. It accepts image uploads and returns predictions about plant diseases and remediation steps.

## Base URL
```
http://localhost:8080
```

## Endpoints

### 1. API Information
**GET** `/`

Returns basic API information and available endpoints.

**Response:**
```json
{
  "message": "Plant Disease Detection API",
  "version": "1.0",
  "endpoints": {
    "/predict": "POST - Upload image for plant disease prediction",
    "/health": "GET - Health check"
  }
}
```

### 2. Plant Disease Prediction
**POST** `/predict`

Upload an image for plant disease prediction.

**Request:**
- Content-Type: `multipart/form-data`
- Body: Form data with `file` field containing the image

**Supported file formats:** JPG, JPEG, PNG, GIF

**Success Response (200):**
```json
{
  "success": true,
  "prediction": {
    "plant_name": "Tomato",
    "disease_name": "Early Blight",
    "remediation": {
      "1": "Remove affected leaves immediately",
      "2": "Apply fungicide spray weekly",
      "3": "Improve air circulation around plants"
    }
  }
}
```

**Error Responses:**
- **400 Bad Request:**
  ```json
  {
    "error": "No file provided"
  }
  ```
  ```json
  {
    "error": "No file selected"
  }
  ```
  ```json
  {
    "error": "Invalid file type. Only jpg, jpeg, png, gif allowed"
  }
  ```

- **500 Internal Server Error:**
  ```json
  {
    "error": "Error message describing the issue"
  }
  ```

### 3. Health Check
**GET** `/health`

Check if the API is running.

**Response:**
```json
{
  "status": "healthy"
}
```

## Flutter Integration Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PlantDiseaseApi {
  static const String baseUrl = 'http://your-server-url:8080';
  
  static Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    
    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    
    if (response.statusCode == 200) {
      return json.decode(responseString);
    } else {
      throw Exception('Failed to predict: ${json.decode(responseString)['error']}');
    }
  }
  
  static Future<bool> healthCheck() async {
    var response = await http.get(Uri.parse('$baseUrl/health'));
    return response.statusCode == 200;
  }
}
```

## Deployment Options for Flutter Integration

1. **Cloud Deployment:** Deploy to Google Cloud Run, AWS, or Heroku
2. **Local Development:** Run locally during development
3. **Docker:** Use the provided Dockerfile for containerized deployment

## CORS Support
The API includes CORS headers to allow cross-origin requests from Flutter web applications.
