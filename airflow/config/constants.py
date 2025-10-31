# airflow/config/constants.py
CITY_NAME = "Lisbon"
COUNTRY = "PT"
START_YEAR = 2015


TIMEZONE = "Europe/Lisbon"

GEOCODING_API_URL = "https://geocoding-api.open-meteo.com/v1/search"
WEATHER_API_URL = "https://archive-api.open-meteo.com/v1/archive"

# Minimal set of daily weather variables for summary reporting.
# Open-Meteo provides temperature in degrees Celsius (°C) by default.
# See: https://open-meteo.com/en/docs for data format and measurement details.


DAILY_VARIABLES = [
    "temperature_2m_max",  # Max air temp for the day (°C), measured at 2 meters above ground.
    "temperature_2m_min",  # Min air temp for the day (°C), measured at 2 meters above ground.
    "weather_code",        # WMO code for main weather type that day.
]



# === Year Range & Fetch Direction Configuration ===

FORWARD = "forward"
BACKWARD = "backward"
DIRECTION = FORWARD   # Set to FORWARD or BACKWARD as needed

START_YEAR = 2015     # Anchor year (first if forward, last if backward)
NUM_YEARS = 5         # How many years to fetch, including anchor
