# Project constants and ETL/helper imports
from config.constants import (
    DB_PATH, CITY_NAME, COUNTRY, WEATHER_API_URL,
    START_YEAR, NUM_YEARS, DIRECTION, DAILY_VARIABLES,
    JULIA_SUMMARY_SCRIPT_PATH, R_ANIMATION_SCRIPT_PATH, REPO_ROOT
)
from helpers.db_utils import create_weather_table
from helpers.db_loader import insert_weather_data
from helpers.weather_api import fetch_weather_data
from helpers.date_utils import get_interval_start_to_end_dates
from helpers.sqlite_utils import export_sqlite_to_csv_with_polars

from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from datetime import datetime

"""
Weather ETL Full Pipeline DAG

- Automates weather data extraction, transformation, and database loading
- Exports summary data for downstream analysis and visualization
- Runs Julia and R post-processing for advanced summaries and animated plots

DAG Tasks:
    1. Create weather DB table if missing
    2. Prepare date ranges for API
    3. Fetch weather data (external API)
    4. Insert data into DB
    5. Export DB to CSV
    6. Run Julia summary script
    7. Run R animation (animated summary MP4)
All steps are atomic and reusable, for modular pipeline development.
"""

@dag(
    dag_id='weather_etl_full_pipeline_dag',
    schedule='@daily',
    start_date=datetime(2025, 11, 22),
    catchup=False,
    tags=['weather', 'etl', 'db', 'date', 'api', 'export', 'julia', 'r']
)
def weather_etl_full_pipeline_dag():
    # 1. Create weather table (idempotent)
    @task()
    def t_create_weather_table():
        """Ensure database table for weather data exists (creates if missing)"""
        create_weather_table(DB_PATH)
        print(f"Ensured weather table exists at {DB_PATH}")

    # 2. Prepare date range for API request
    @task()
    def t_prepare_date_range():
        """Compute start/end dates for API query given config constants"""
        start_date, end_date = get_interval_start_to_end_dates(START_YEAR, NUM_YEARS, DIRECTION)
        print(f"Date range: {start_date} to {end_date}")
        return {"start_date": start_date, "end_date": end_date}

    # 3. Fetch weather data from API
    @task()
    def t_fetch_weather_data(dates):
        """Call weather API and fetch data for specified date range"""
        weather_data = fetch_weather_data(
            CITY_NAME, COUNTRY, WEATHER_API_URL,
            dates['start_date'], dates['end_date'], DAILY_VARIABLES
        )
        print(f"Fetched weather data for {CITY_NAME}, {COUNTRY}")
        return weather_data

    # 4. Insert collected weather data into DB
    @task()
    def t_insert_weather_data(weather_data):
        """Insert fetched weather data into database"""
        insert_weather_data(DB_PATH, weather_data)
        print("Weather data inserted.")

    # 5. Export DB to CSV using Polars (for R/Julia downstream use)
    @task()
    def t_export():
        """Export SQLite weather data to CSV; enables advanced cross-language viz"""
        export_sqlite_to_csv_with_polars()
        print("Export process completed.")

    # 6. Run Julia summary script (advanced stats/update)
    julia_summary = BashOperator(
        task_id="julia_summary",
        bash_command=f'julia --project={REPO_ROOT} {JULIA_SUMMARY_SCRIPT_PATH}',
        cwd=REPO_ROOT
    )

    # 7. Run R animation script for MP4 visualization (final output)
    r_animation = BashOperator(
        task_id="r_weather_animation",
        bash_command=f"Rscript {R_ANIMATION_SCRIPT_PATH}",
        cwd=REPO_ROOT
    )

    # Chain tasks and data flow (>> for dependencies)
    table = t_create_weather_table()
    dates = t_prepare_date_range()
    weather_data = t_fetch_weather_data(dates)
    insert = t_insert_weather_data(weather_data)
    export = t_export()

    # Final chain includes Julia and R steps
    table >> dates >> weather_data >> insert >> export >> julia_summary >> r_animation

# DAG registration (entry point for Airflow)
weather_etl_full_pipeline_dag()
