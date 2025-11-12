import requests
from pprint import pprint
from .geocode_utils import get_city_coordinates
from .date_utils import get_interval_start_to_end_dates
from ..config.constants import CITY_NAME, COUNTRY, WEATHER_API_URL, DAILY_VARIABLES, START_YEAR, TIMEZONE, NUM_YEARS, DIRECTION

# Get date strings for the requested interval
start_date, end_date = get_interval_start_to_end_dates(START_YEAR, NUM_YEARS, DIRECTION)

def fetch_weather_data(
    city_name, country, weather_api_url, start_date, end_date,
    daily_variables=DAILY_VARIABLES, timezone=TIMEZONE
):
    lat, lon = get_city_coordinates(city_name, country)
    params = {
        'latitude': lat,
        'longitude': lon,
        'start_date': start_date,
        'end_date': end_date,
        'daily': ','.join(daily_variables),
        'timezone': timezone,
    }
    try:
        response = requests.get(weather_api_url, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()
        return data
    except Exception as e:
        print(f"Error fetching weather API: {e}")
        return {}