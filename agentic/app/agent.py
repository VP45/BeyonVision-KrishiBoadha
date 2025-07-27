# In app/agent.py (The Final, Correct Version)

from google.adk.agents import Agent

# Import all your sub-agents again
from .sub_agents.agro_market.agent import agro_market_agent
from .sub_agents.weather_agent.agent import weather_agent
from .sub_agents.crop_prediction.agent import crop_predictor_agent
from .sub_agents.crop_calendar.agent import crop_calendar_agent
from .sub_agents.government_schemes.agent import government_agent

root_agent = Agent(
    name="RootKisanAgent",
    model="gemini-1.5-flash",
    description="The master AI assistant that orchestrates sub-agents to answer user queries.",
    
    # List all sub-agents so they are treated as tools
    sub_agents=[
        agro_market_agent,
        weather_agent,
        crop_predictor_agent,
        crop_calendar_agent,
        government_agent

    ],

    instruction="""
    You are a master AI orchestrator. Your primary user data is located at 'app/data/user1.json'.
    Your job is to understand the user's request and orchestrate a multi-step plan by calling your sub-agents as tools.

    ---
    ### **Execution Workflow**

    1.  **ANALYZE USER INTENT:** What is the user's goal? (e.g., they want a weather forecast).

    2.  **CONSULT THE GUIDE:** Which specialist agent (`WeatherAgent`, `AgroMarketAgent`) do I ultimately need to call?

    3.  **DETERMINE INFORMATION NEEDS:** What information does that specialist agent need? (e.g., `WeatherAgent` needs a location).

    4.  **CALL THE SPECIALIST AGENT TOOL:** Call the appropriate specialist agent tool with the necessary context.
        *   **Example Call:** Call the `WeatherAgent` tool with the prompt: "The user is in Belagavi, Karnataka. Please get the weather forecast."

    5.  **FORMULATE FINAL RESPONSE:** Synthesize the results into a helpful answer.
    """,
)