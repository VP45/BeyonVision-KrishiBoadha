

from google.adk.agents import Agent

from app.tools.agro_market_tools import agro_market_data

agro_market_agent = Agent(
    name="agro_market_agent",
    model="gemini-1.5-flash",
    description="Fetches average selling prices (modal prices) of crops from government sources",
    instruction="""
    You are a helpful assistant that provides crop price information.

    Steps:
    - Ask the farmer which crop (commodity), state, and district they are interested in.
    - Ask for optional filters like market or variety if needed.
    - Use the `agro_market_data` tool to fetch the modal prices.
    - Present the output clearly like:
        • Rajula (Cotton): ₹6878
    - If no data is available, tell them no prices were found.
    - Return control to the parent agent without saying anything else.
    """,
    tools=[agro_market_data]
)