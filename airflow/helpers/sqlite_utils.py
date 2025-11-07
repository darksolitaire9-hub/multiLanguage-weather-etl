import os
import sqlite3
import polars as pl
from helpers.csv_path_writer import save_exported_csv_path_if_missing
from config.constants import DB_PATH, EXPORT_QUERY, EXPORT_CSV

def export_sqlite_to_csv_with_polars(
    sqlite_db_path=DB_PATH,
    query=EXPORT_QUERY,
    output_csv=EXPORT_CSV,
    sample_lines=5,
    overwrite=False
):
    os.makedirs(os.path.dirname(output_csv), exist_ok=True)
    # Check for existing non-empty CSV
    if os.path.exists(output_csv) and os.path.getsize(output_csv) > 0 and not overwrite:
        print(f"CSV '{output_csv}' already exists and is non-empty. Skipping export.")
        return False
    try:
        with sqlite3.connect(sqlite_db_path) as conn:
            df = pl.read_database(query, conn)
        if df.is_empty():
            print("No data found in the database. Export skipped.")
            return False
        df.write_csv(output_csv)
        print(f"✅ Data exported to '{output_csv}'")
        print("=" * 45)
        print("Sample of exported data:")
        print(df.head(sample_lines))  # Only uses Polars, no pandas
        print("=" * 45)

        # Safely save export path only if record file does not exist yet
        save_exported_csv_path_if_missing("airflow/config/export_csv_path.txt", output_csv)
        return True
        
    except Exception as e:
        print(f"❌ Error during export: {e}")
        return False

if __name__ == "__main__":
    from config.constants import DB_PATH
    from helpers.db_utils import create_weather_table
    from helpers.db_loader import insert_weather_data
    from helpers.weather_api import fetch_weather_data
    from helpers.date_utils import get_interval_start_to_end_dates
    from config.constants import (
        CITY_NAME, COUNTRY, WEATHER_API_URL,
        START_YEAR, NUM_YEARS, DIRECTION, DAILY_VARIABLES
    )

    # 1. Ensure DB and table exist
    create_weather_table(DB_PATH)

    # 2. Prepare date range
    start_date, end_date = get_interval_start_to_end_dates(START_YEAR, NUM_YEARS, DIRECTION)

    # 3. Fetch weather data via API
    weather_data = fetch_weather_data(
        CITY_NAME, COUNTRY, WEATHER_API_URL,
        start_date, end_date, DAILY_VARIABLES
    )

    # 4. Insert records into DB (idempotent, safe duplicates)
    insert_weather_data(DB_PATH, weather_data)

    # 5. Export (skip if already has data)
    export_sqlite_to_csv_with_polars()

    print("Export process completed.")
