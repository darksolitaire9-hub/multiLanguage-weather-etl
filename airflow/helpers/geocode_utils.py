import requests

def get_city_coordinates(city_name, country=None):
    """
    Returns (latitude, longitude) for city_name using Open-Meteo's geocoding API.
    If country is supplied, narrows the search.
    """
    url = "https://geocoding-api.open-meteo.com/v1/search"
    params = {'name': city_name, 'count': 1}
    if country:
        params['country'] = country
    response = requests.get(url, params=params, timeout=10)
    data = response.json()
    print(data)
    # result = data['results'][0]
    # return result['latitude'], result['longitude']

