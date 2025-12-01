import requests
from typing import Optional
from pydantic import ValidationError

# Import schemas
from helpers.schemas import WeatherResponse

# Import helpers
from helpers.geocode_utils import get_city_coordinates
from helpers.date_utils import get_interval_start_to_end_dates # Needed for default calculation

# Import all constants for defaults
from config.constants import (
    CITY_NAME, COUNTRY, WEATHER_API_URL, DAILY_VARIABLES, 
    START_YEAR, TIMEZONE, NUM_YEARS, DIRECTION
)

# Pre-calculate default dates if you want them as defaults
# (Note: This runs on import, so it fixes the dates to "today")
DEFAULT_START, DEFAULT_END = get_interval_start_to_end_dates(START_YEAR, NUM_YEARS, DIRECTION)

def fetch_weather_data(
    city_name: str = CITY_NAME, 
    country: str = COUNTRY, 
    weather_api_url: str = WEATHER_API_URL, 
    start_date: str = DEFAULT_START, # Uses the calculated string
    end_date: str = DEFAULT_END,     # Uses the calculated string
    daily_variables: list = DAILY_VARIABLES, 
    timezone: str = TIMEZONE
) -> Optional[WeatherResponse]:
    """
    Fetches weather data using Project Constants as defaults.
    Allows running without arguments to fetch the 'configured' city/range.
    """
    
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
        return WeatherResponse.model_validate(response.json())

    except ValidationError as e:
        print(f"❌ Validation Error for {city_name}: {e}")
        return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None
