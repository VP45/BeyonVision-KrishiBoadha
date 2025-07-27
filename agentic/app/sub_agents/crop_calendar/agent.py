# In app/sub_agents/crop_calendar/agent.py

from google.adk.agents import Agent
from google.adk.tools.agent_tool import AgentTool


from app.sub_agents.satellite_soil_agent.agent import create_soil_agent

crop_calendar_agent = Agent(
    name="CropCalendarAgent",
    model="gemini-1.5-flash",
    description=(
        "Agent that creates a detailed, step-by-step crop calendar in JSON format, "
        "tailored to a specific field based on soil analysis and (optionally) weather forecasting."
    ),
    instruction=("""
    (Your detailed instructions remain the same)
    """),
    tools=[
        AgentTool(agent=create_soil_agent()),
    ],
)