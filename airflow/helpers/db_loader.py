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
# Integration with Pydantic:
#   - This module now accepts strictly typed `WeatherResponse` objects.
#   - It uses Pydantic's validation guarantees to safely access data via dot notation.
#
# Usage:
#   from helpers.db_loader import insert_weather_data
#   insert_weather_data(DB_PATH, weather_data_object)
#
# Dependencies:
#   - sqlite3 (Python standard library)
#   - helpers.schemas (for type checking)
# =====================================================

import sqlite3
import os
from helpers.schemas import WeatherResponse

def insert_weather_data(db_path: str, weather_data: WeatherResponse):
    """
    Inserts daily weather records into the weather_daily table in SQLite DB.

    This function transforms the columnar data from the Pydantic WeatherResponse 
    object (lists of values) into row-based records for database insertion.

    Args:
        db_path (str): Path to the SQLite .db file.
        weather_data (WeatherResponse): Validated Pydantic data object containing daily weather series.
            
    Side Effects:
        - Creates the database directory if it does not exist.
        - Inserts each day's observations as a new record in 'weather_daily'.
        - If a date already exists (unique constraint), the record is ignored (Idempotency).
        - Prints the count of successfully inserted rows.
    """
    # Ensure the target directory exists
    os.makedirs(os.path.dirname(db_path), exist_ok=True)

    # Access data directly via Pydantic dot notation (Clean & Safe)
    daily = weather_data.daily
    
    # --- DATA PREPARATION ---
    # We use 'or []' to handle Optional fields safely.
    # If the API returned None for a field (e.g. because it wasn't requested),
    # we treat it as an empty list. This ensures zip() creates 0 records
    # instead of raising a TypeError, preventing the pipeline from crashing.
    times = daily.time
    temp_max = daily.temperature_2m_max or []
    temp_min = daily.temperature_2m_min or []
    w_codes  = daily.weather_code or []

    # --- COLUMN TO ROW TRANSFORMATION ---
    # The API provides independent lists: [Date1, Date2], [Temp1, Temp2]
    # The DB requires rows: (Date1, Temp1, ...), (Date2, Temp2, ...)
    # zip() performs this transposition, stopping at the shortest list length.
    records = list(zip(times, temp_max, temp_min, w_codes))

    if not records:
        print("⚠️ No valid weather records found to insert (lists were empty or mismatched).")
        return

    # --- DATABASE TRANSACTION ---
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # Uses 'INSERT OR IGNORE' to maintain idempotency (skips existing dates)
        cursor.executemany("""
            INSERT OR IGNORE INTO weather_daily (date, temp_max, temp_min, weather_code)
            VALUES (?, ?, ?, ?)
        """, records)
        
        conn.commit()
        print(f"✅ Inserted {cursor.rowcount} new days into {db_path} (duplicates ignored)")
    
    except sqlite3.Error as e:
        print(f"❌ Database Error: {e}")
    
    finally:
        conn.close()


# =====================================================
# Standalone Test Block
# =====================================================
if __name__ == "__main__":
    from config.constants import (
        DB_PATH, CITY_NAME, COUNTRY, WEATHER_API_URL, 
        DAILY_VARIABLES, START_YEAR, TIMEZONE, NUM_YEARS, DIRECTION
    )
    from helpers.geocode_utils import get_city_coordinates
    from helpers.date_utils import get_interval_start_to_end_dates
    from helpers.db_utils import create_weather_table
    # Note: We import the Pydantic-enabled fetcher now!
    from helpers.weather_api import fetch_weather_data 

    print("--- Starting DB Loader Test ---")

    # 1. Ensure the database and table exist
    create_weather_table(DB_PATH)

    # 2. Prepare date range
    start_date, end_date = get_interval_start_to_end_dates(START_YEAR, NUM_YEARS, DIRECTION)

    # 3. Fetch weather data (Returns a WeatherResponse object now)
    print(f"Fetching weather data for {CITY_NAME}...")
    weather_object = fetch_weather_data(
        CITY_NAME, COUNTRY, WEATHER_API_URL, 
        start_date, end_date, DAILY_VARIABLES, TIMEZONE
    )

    if weather_object:
        # 4. Test the insert function with the Object
        print("Loading validated weather data into database...")
        insert_weather_data(DB_PATH, weather_object)
    else:
        print("❌ Test Failed: Could not fetch weather data.")
