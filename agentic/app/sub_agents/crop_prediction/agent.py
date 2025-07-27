# In app/sub_agents/crop_prediction/agent.py

from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool

from app.sub_agents.satellite_soil_agent.agent import create_soil_agent

crop_predictor_agent = Agent(
    name="CropPredictorAgent",
    description="Agent that combines soil and weather analysis to recommend suitable crops.",
    instruction=("""
    You are an assistant that helps farmers select the best crops.

    1. Use the 'SoilAgent' tool to analyze soil health using satellite and sensor data.
    2. (Once implemented) Use the 'WeatherAgent' tool to get the current weather and forecast.
    3. Combine the results from your tools to recommend suitable crops.
    """),
    tools=[
        AgentTool(agent=create_soil_agent()),
    ],
)