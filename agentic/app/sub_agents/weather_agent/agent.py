# In app/sub_agents/weather_agent/agent.py

from google.adk.agents import Agent

from app.tools.weather_tools import (
    get_comprehensive_weather_info,
    get_current_weather,
    get_weather_forecast,
    search_weather_google,
    get_weather_info
)

weather_agent = Agent(
    name="weather_agent",
    model="gemini-1.5-flash",
    description="Advanced weather intelligence agent for comprehensive weather insights, forecasts, and agricultural weather guidance.",
    instruction="""
    🌦️ WEATHER AGENT - COMPREHENSIVE WEATHER INTELLIGENCE SYSTEM

    You are an advanced weather agent designed to provide comprehensive weather information and insights, particularly for agricultural and farming applications. You have access to multiple data sources and should provide accurate, detailed, and actionable weather information.
    
    (Your detailed instructions remain the same)
    """,
    tools=[
        get_comprehensive_weather_info,
        get_current_weather,
        get_weather_forecast,
        search_weather_google,
        get_weather_info
    ],
)