from google.adk.agents import Agent

from app.tools.satellite_soil_tools import read_soil_excel

def create_soil_agent():
    """Factory function to create a new instance of the SoilAgent."""
    return Agent(
        name="SoilAgent",
        model="gemini-1.5-flash",
        description="Analyzes soil health using satellite and sensor data.",
        instruction=(
            "You are a satellite-based soil and vegetation analysis expert. "
            "Use the `read_soil_excel` tool to retrieve recent data and analyze it."
        ),
        tools=[read_soil_excel],
    )