import requests
from config.constants import BASE_URL

def get_city_coordinates(city_name, country=None):
    """
    Returns (latitude, longitude) for city_name using Open-Meteo's geocoding API.
    If country is supplied, narrows the search.
    Raises ValueError if no result found.
    """
    url = BASE_URL
    params = {'name': city_name, 'count': 1}
    if country:
        params['country'] = country
    response = requests.get(url, params=params, timeout=10)
    data = response.json()
    results = data.get('results', [])
    if results:
        latitude = results[0]['latitude']
        longitude = results[0]['longitude']
        return latitude, longitude
    else:
        raise ValueError(
            f"No results found for city '{city_name}' with country '{country}'. API response: {data}"
        )


