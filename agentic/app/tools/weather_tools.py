import requests
import json
from typing import Dict, Any
from datetime import datetime
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# API Key - Loaded from .env file
OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")

def get_current_weather(location: str) -> Dict[str, Any]:
    """
    Fetches comprehensive current weather information from OpenWeather API.
    
    Args:
        location: City name, state/country (e.g., "New York, NY" or "London, UK")
    
    Returns:
        Dictionary containing weather data or error information
    """
    try:
        if not OPENWEATHER_API_KEY or OPENWEATHER_API_KEY == "YOUR_OPENWEATHER_API_KEY":
            return {
                "success": False,
                "error": "OpenWeather API key not configured in .env file"
            }

        url = f"http://api.openweathermap.org/data/2.5/weather?q={location}&appid={OPENWEATHER_API_KEY}&units=metric"
        response = requests.get(url, timeout=10)
        data = response.json()

        if response.status_code == 200:
            return {
                "success": True,
                "location": f"{data['name']}, {data['sys']['country']}",
                "temperature": data['main']['temp'],
                "feels_like": data['main']['feels_like'],
                "humidity": data['main']['humidity'],
                "pressure": data['main']['pressure'],
                "visibility": data.get('visibility', 'N/A'),
                "description": data['weather'][0]['description'].title(),
                "wind_speed": data.get('wind', {}).get('speed', 'N/A'),
                "wind_direction": data.get('wind', {}).get('deg', 'N/A'),
                "cloudiness": data.get('clouds', {}).get('all', 'N/A'),
                "sunrise": datetime.fromtimestamp(data['sys']['sunrise']).strftime('%H:%M:%S'),
                "sunset": datetime.fromtimestamp(data['sys']['sunset']).strftime('%H:%M:%S'),
                "timestamp": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
        else:
            return {
                "success": False,
                "error": f"OpenWeather API Error: {data.get('message', 'Unknown error')}",
                "status_code": response.status_code
            }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error fetching weather from OpenWeather: {str(e)}"
        }

def get_weather_forecast(location: str, days: int = 5) -> Dict[str, Any]:
    """
    Fetches weather forecast for the specified location and number of days.
    
    Args:
        location: City name, state/country
        days: Number of days for forecast (1-5)
    
    Returns:
        Dictionary containing forecast data or error information
    """
    try:
        if not OPENWEATHER_API_KEY or OPENWEATHER_API_KEY == "YOUR_OPENWEATHER_API_KEY":
            return {
                "success": False,
                "error": "OpenWeather API key not configured in .env file"
            }
            
        url = f"http://api.openweathermap.org/data/2.5/forecast?q={location}&appid={OPENWEATHER_API_KEY}&units=metric"
        response = requests.get(url, timeout=10)
        data = response.json()

        if response.status_code == 200:
            forecasts = []
            # 8 forecasts per day (3-hour intervals)
            for item in data['list'][:days * 8]:
                forecasts.append({
                    "datetime": item['dt_txt'],
                    "temperature": item['main']['temp'],
                    "description": item['weather'][0]['description'].title(),
                    "humidity": item['main']['humidity'],
                    "wind_speed": item.get('wind', {}).get('speed', 'N/A'),
                    "precipitation": item.get('rain', {}).get('3h', 0) + item.get('snow', {}).get('3h', 0)
                })
            
            return {
                "success": True,
                "location": f"{data['city']['name']}, {data['city']['country']}",
                "forecasts": forecasts
            }
        else:
            return {
                "success": False,
                "error": f"Forecast API Error: {data.get('message', 'Unknown error')}"
            }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error fetching forecast: {str(e)}"
        }

def get_comprehensive_weather_info(location: str, include_forecast: bool = False) -> Dict[str, Any]:
    """
    Fetches comprehensive weather information including current conditions and optional forecast.
    
    Args:
        location: City name, state/country
        include_forecast: Whether to include forecast data
    
    Returns:
        Dictionary containing comprehensive weather data
    """
    try:
        # Get current weather
        current_weather = get_current_weather(location)
        
        if not current_weather["success"]:
            return current_weather
        
        result = {
            "success": True,
            "current_weather": current_weather,
            "forecast": None
        }
        
        # Add forecast if requested
        if include_forecast:
            forecast_data = get_weather_forecast(location, days=3)
            if forecast_data["success"]:
                result["forecast"] = forecast_data
            else:
                result["forecast_error"] = forecast_data.get("error", "Failed to get forecast")
        
        return result
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Error getting comprehensive weather info: {str(e)}"
        }

def search_weather_google(query: str) -> Dict[str, Any]:
    """
    Fallback weather search using Google (placeholder implementation).
    This function serves as a fallback when OpenWeather API fails.
    
    Args:
        query: Weather search query
    
    Returns:
        Dictionary containing search results or error information
    """
    try:
        # Note: This is a placeholder implementation
        # In a real scenario, you would implement Google Custom Search API
        
        return {
            "success": False,
            "error": "Google Search fallback not implemented. Please configure Google Custom Search API.",
            "suggestion": "Try rephrasing your location or check if the location name is correct."
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Error in Google search fallback: {str(e)}"
        }

def get_weather_info(city: str) -> str:
    """
    Legacy function for backward compatibility.
    Fetches and formats current weather information.
    """
    weather_data = get_current_weather(city)
    if weather_data["success"]:
        return f"The current temperature in {weather_data['location']} is {weather_data['temperature']}°C with {weather_data['description']}."
    else:
        return f"Error fetching weather: {weather_data['error']}"

