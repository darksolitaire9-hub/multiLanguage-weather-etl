# helpers/db_loader.py
# =====================================================
# Module: db_loader
#
# Loader functions for persisting weather data 
# from API responses to the SQLite database.
#
# This module provides helpers to insert normalized
# weather data (daily summary) fetched from the Open-Meteo
# Weather API into the local project SQLite database.
#
# Design Decision – Duplicates and Idempotency:
# -----------------------------------------------------
# For this pipeline, we enforce a UNIQUE constraint on the `date`
# column in the target DB and use the `INSERT OR IGNORE` statement.
#
# This approach ensures that:
#   - Each day is loaded only once, even if the ETL is rerun or the API is called multiple times.
#   - If an attempt is made to insert data for a date that already exists, the insert is ignored.
#   - We avoid possible corruption or loss of historical data by never overwriting existing records without explicit intent.
#
# Rationale:
#   - Weather API data for historic periods is generally stable and should not be retroactively updated.
#   - Safety: Rerunning the pipeline (e.g., after interruptions or updates) will not produce duplicates or overwrite prior results.
#   - Professional data workflows prioritize data integrity and idempotency unless routine corrections are required (in which case, "REPLACE" logic would be used).
#
# Usage:
#   from helpers.db_loader import insert_weather_data
#   insert_weather_data(DB_PATH, weather_data)
#
# Standalone test:
#   python helpers/db_loader.py
#
# Dependencies:
#   - sqlite3 (Python standard library)
#   - helpers.geocode_utils, helpers.date_utils (for script-mode API fetch)
#   - requests (for script-mode API fetch)
# =====================================================

# ---- [End] ----
import sqlite3
import os

def insert_weather_data(db_path, weather_data):
    """
    Inserts daily weather records into weather_daily table in SQLite DB.

    Args:
        db_path (str): Path to the SQLite .db file.
        weather_data (dict): Parsed Open-Meteo API response.
            Expected format:
            {
                'daily': {
                    'time': [...],  # list of date strings (YYYY-MM-DD)
                    'temperature_2m_max': [...],  # list of daily max temp (float)
                    'temperature_2m_min': [...],  # list of daily min temp (float)
                    'weather_code': [...],        # list of WMO weather codes (int)
                }
            }
    Side Effects:
        Inserts each day's observations as a new record in 'weather_daily'.
        If a date already exists (unique), record is ignored.
        Prints count of attempted loads.

    Returns:
        None
    """
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    daily = weather_data.get('daily', {})
    # Prepare records as tuples for insertion
    records = list(zip(
        daily.get('time', []),
        daily.get('temperature_2m_max', []),
        daily.get('temperature_2m_min', []),
        daily.get('weather_code', [])
    ))

    if not records:
        print("No weather data to insert.")
        return

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.executemany("""
        INSERT OR IGNORE INTO weather_daily (date, temp_max, temp_min, weather_code)
        VALUES (?, ?, ?, ?)
    """, records)
    conn.commit()
    conn.close()
    print(f"Inserted up to {len(records)} days into {db_path} (duplicates ignored)")


if __name__ == "__main__":
    from config.constants import DB_PATH, CITY_NAME, COUNTRY, WEATHER_API_URL, DAILY_VARIABLES, START_YEAR, TIMEZONE, NUM_YEARS, DIRECTION
    from helpers.geocode_utils import get_city_coordinates
    from helpers.date_utils import get_interval_start_to_end_dates
    from helpers.db_utils import create_weather_table
    import requests

    # Ensure the database and table exist before loading
    create_weather_table(DB_PATH)

    # Prepare date range for the test fetch (using config)
    start_date, end_date = get_interval_start_to_end_dates(START_YEAR, NUM_YEARS, DIRECTION)

    # Fetch weather data for the configured city/country
    lat, lon = get_city_coordinates(CITY_NAME, COUNTRY)
    params = {
        'latitude': lat,
        'longitude': lon,
        'start_date': start_date,
        'end_date': end_date,
        'daily': ','.join(DAILY_VARIABLES),
        'timezone': TIMEZONE,
    }
    print("Fetching weather data...")
    response = requests.get(WEATHER_API_URL, params=params, timeout=60)
    weather_data = response.json()

    # Test the insert_weather_data function
    print("Loading weather data into database...")
    insert_weather_data(DB_PATH, weather_data)
