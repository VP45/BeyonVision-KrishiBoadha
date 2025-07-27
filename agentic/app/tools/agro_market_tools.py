import requests

def agro_market_data(
    state: str,
    district: str,
    grade: str = "FAQ",
    market: str = None,
    commodity: str = None,
    variety: str = None,
    offset: int = 0,
    limit: int = 10
):
    params = {
        "api-key": "579b464db66ec23bdd00000197d9af2e2e3e46cb5be27ca8f634ec25",
        "format": "json",
        "filters[state.keyword]": state,
        "filters[district]": district,
        "filters[grade]": grade,
        "offset": offset,
        "limit": limit
    }

    if market:
        params["filters[market]"] = market
    if commodity:
        params["filters[commodity]"] = commodity
    if variety:
        params["filters[variety]"] = variety

    response = requests.get(
        "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070",
        params=params
    )

    data = response.json().get("records", [])
    
    return [
        {
            "market": r["market"],
            "commodity": r["commodity"],
            "modal_price": r["modal_price"]
        } for r in data
    ]
