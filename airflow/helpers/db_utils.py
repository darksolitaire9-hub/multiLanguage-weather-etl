import sqlite3
import os

def create_weather_table(db_path):
    """
    Create the weather_daily table in the specified SQLite database file.
    - db_path: str, path to the .db SQLite file (will be created if not exists).
    The operation is idempotent (safe to run multiple times).
    """
    # Ensure directory exists
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS weather_daily (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            temp_max REAL,
            temp_min REAL,
            weather_code INTEGER
        )
    """)
    conn.commit()
    conn.close()
