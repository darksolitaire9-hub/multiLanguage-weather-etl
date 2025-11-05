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
# Usage:
#   from helpers.db_loader import insert_weather_data
#   insert_weather_data(DB_PATH, weather_data)
#
#   For standalone testing, run this module directly:
#   python helpers/db_loader.py
#
# Dependencies:
#   - sqlite3 (Python standard library)
#   - helpers.geocode_utils, helpers.date_utils (for script-mode API fetch)
#   - requests (for script-mode API fetch)
# =====================================================

import sqlite3

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
        Prints count of loaded records.

    Returns:
        None
    """
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
        INSERT INTO weather_daily (date, temp_max, temp_min, weather_code)
        VALUES (?, ?, ?, ?)
    """, records)
    conn.commit()
    conn.close()
    print(f"Inserted {len(records)} days into {db_path}")

