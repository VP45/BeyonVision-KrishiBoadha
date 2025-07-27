
from google.adk.tools.tool_context import ToolContext # Import ToolContext
from io import BytesIO
import pandas as pd
import requests

# Add tool_context to the function's arguments
def read_soil_excel(file_url: str, tool_context: ToolContext) -> str:
    """
    Reads and returns raw soil/vegetation data from a Sentinel-2 Excel file.

    This tool is useful for reasoning over plant health trends by providing recent
    vegetation indices like NDVI, SAVI, EVI, NDWI, MNDWI, and CI. It returns the
    top 20 most recent records.

    Args:
        file_url: The public URL of the Excel file to be processed.
        tool_context: The context for the tool, used for caching data.

    Returns:
        A string representation of a pandas DataFrame containing the most recent
        20 rows of soil and vegetation data, or an error message if processing fails.
    """
    # Initialize a cache in the shared state if it doesn't exist
    if 'soil_data_cache' not in tool_context.state:
        tool_context.state['soil_data_cache'] = {}

    # Check if data for this URL is already in our shared cache
    if file_url in tool_context.state['soil_data_cache']:
        print(f"--- Using cached data for {file_url} ---")
        df = tool_context.state['soil_data_cache'][file_url]
    else:
        print(f"--- Fetching and processing new data for {file_url} ---")
        try:
            response = requests.get(file_url)
            response.raise_for_status()
            excel_file = BytesIO(response.content)

            df = pd.read_excel(excel_file, sheet_name="final_final_data")
            df['current_date'] = pd.to_datetime(df['current_date'])
            df = df.sort_values(by='current_date', ascending=False)

            # Store the processed DataFrame in the shared cache
            tool_context.state['soil_data_cache'][file_url] = df

        except Exception as e:
            return f"Failed to process the Excel file: {str(e)}"

    # Process and return the top 20 records from the DataFrame
    records = df[['current_date', 'NDVI', 'SAVI', 'EVI', 'NDWI', 'MNDWI', 'CI']].head(20)
    return records.to_string(index=False)