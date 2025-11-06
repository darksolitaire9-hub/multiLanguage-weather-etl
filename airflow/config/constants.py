# airflow/config/constants.py
# ===========================================
# Central project configuration and constants.
# Edit these to change run behavior, API targets, 
# time ranges, and output locations project-wide.
# ===========================================

# --- Location settings ---
CITY_NAME = "Lisbon"         # Main city for weather data extraction
COUNTRY = "PT"               # Country code (ISO Alpha-2 format)
TIMEZONE = "Europe/Lisbon"   # Target timezone for API queries

# --- API endpoints ----
GEOCODING_API_URL = "https://geocoding-api.open-meteo.com/v1/search"   # URL for geocoding requests (lat/lon)
WEATHER_API_URL = "https://archive-api.open-meteo.com/v1/archive"      # Weather API endpoint for historical data

# --- SQLite and Export Config ---
DB_PATH = "data/weather.db"
TABLE_NAME = "weather_daily"
EXPORT_QUERY = f"SELECT * FROM {TABLE_NAME}"
EXPORT_CSV_DIR = "data/exported_csvs"


# --- Weather data configuration ---
DAILY_VARIABLES = [
    "temperature_2m_max",  # Max air temp for the day (°C), measured at 2 meters above ground
    "temperature_2m_min",  # Min air temp for the day (°C), measured at 2 meters above ground
    "weather_code",        # WMO code for main daily weather type
]

# --- Year range and fetch direction ---
FORWARD = "forward"         # Fetch data starting from START_YEAR
BACKWARD = "backward"       # Fetch data going backward from START_YEAR
DIRECTION = FORWARD         # Choose direction (FORWARD/BACKWARD) for current execution

START_YEAR = 2015           # Anchor year (starting point for data retrieval)
NUM_YEARS = 5               # Number of years to include (from anchor)

# ------------------------------------------
# End of configuration
# ------------------------------------------
