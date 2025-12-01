import requests
from typing import Optional
from pydantic import ValidationError

# Import the strict data model we defined
from helpers.schemas import WeatherResponse

# Import existing configuration and helpers
from pprint import pprint
from helpers.geocode_utils import get_city_coordinates
from helpers.date_utils import get_interval_start_to_end_dates
from config.constants import (
    CITY_NAME, COUNTRY, WEATHER_API_URL, DAILY_VARIABLES, 
    START_YEAR, TIMEZONE, NUM_YEARS, DIRECTION
)

# Calculate the time range for our data request
start_date, end_date = get_interval_start_to_end_dates(START_YEAR, NUM_YEARS, DIRECTION)


def fetch_weather_data(
    city_name: str, 
    country: str, 
    weather_api_url: str, 
    start_date: str, 
    end_date: str,
    daily_variables: list = DAILY_VARIABLES, 
    timezone: str = TIMEZONE
) -> Optional[WeatherResponse]:
    """
    Fetches historical weather data from the Open-Meteo API and validates it.

    Args:
        city_name (str): Name of the city to fetch data for.
        country (str): ISO Alpha-2 country code (e.g., "PT").
        weather_api_url (str): The API endpoint URL.
        start_date (str): Start date in YYYY-MM-DD format.
        end_date (str): End date in YYYY-MM-DD format.
        daily_variables (list): List of weather variables to request (e.g., ["temperature_2m_max"]).
        timezone (str): Timezone for the daily aggregation (e.g., "Europe/Lisbon").

    Returns:
        Optional[WeatherResponse]: 
            - Returns a validated `WeatherResponse` object if successful.
            - Returns `None` if the API call fails or the data is invalid.
    """
    
    # 1. Convert City Name -> Latitude/Longitude
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
        # 2. Make the HTTP Request
        response = requests.get(weather_api_url, params=params, timeout=30)
        
        # 3. Check for HTTP Errors (404 Not Found, 500 Server Error, etc.)
        # If status code is 4xx or 5xx, this raises an HTTPError exception.
        response.raise_for_status()
        
        # 4. Validate & Parse Data with Pydantic
        # Instead of returning a raw dictionary, we convert it into a strict Object.
        # If the API returns bad data (e.g., missing fields), this line will crash safely
        # with a ValidationError, protecting our downstream code.
        return WeatherResponse.model_validate(response.json())

    except ValidationError as e:
        print(f"❌ Data Contract Violation for {city_name}:")
        print(f"   The API returned data that doesn't match our schema.")
        print(f"   Details: {e}")
        return None

    except requests.RequestException as e:
        print(f"❌ Network Error fetching data for {city_name}: {e}")
        return None
        
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")
        return None
