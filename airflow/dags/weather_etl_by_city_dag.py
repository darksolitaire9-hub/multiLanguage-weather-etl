# Project constants and helpers
from config.constants import (
    DB_PATH, CITY_NAME, COUNTRY, WEATHER_API_URL,
    START_YEAR, NUM_YEARS, DIRECTION, DAILY_VARIABLES, JULIA_SUMMARY_SCRIPT_PATH
)
from helpers.db_utils import create_weather_table
from helpers.db_loader import insert_weather_data
from helpers.weather_api import fetch_weather_data
from helpers.date_utils import get_interval_start_to_end_dates
from helpers.sqlite_utils import export_sqlite_to_csv_with_polars  # Optional export

# Airflow 3.x core imports
from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from datetime import datetime



from datetime import datetime

@dag(
    dag_id='weather_etl_full_pipeline_dag',
    schedule='@daily',
    start_date=datetime(2025, 11, 22),
    catchup=False,
    tags=['weather', 'etl', 'db', 'date', 'api', 'export', 'julia']
)
def weather_etl_full_pipeline_dag():

    @task()
    def t_create_weather_table():
        create_weather_table(DB_PATH)
        print(f"Ensured weather table exists at {DB_PATH}")

    @task()
    def t_prepare_date_range():
        start_date, end_date = get_interval_start_to_end_dates(START_YEAR, NUM_YEARS, DIRECTION)
        print(f"Date range: {start_date} to {end_date}")
        return {"start_date": start_date, "end_date": end_date}

    @task()
    def t_fetch_weather_data(dates):
        weather_data = fetch_weather_data(
            CITY_NAME, COUNTRY, WEATHER_API_URL,
            dates['start_date'], dates['end_date'], DAILY_VARIABLES
        )
        print(f"Fetched weather data for {CITY_NAME}, {COUNTRY}")
        return weather_data

    @task()
    def t_insert_weather_data(weather_data):
        insert_weather_data(DB_PATH, weather_data)
        print("Weather data inserted.")

    @task()
    def t_export():
        export_sqlite_to_csv_with_polars()
        print("Export process completed.")

    # BashOperator for Julia script
    julia_summary = BashOperator(
    task_id="julia_summary",
    bash_command=f'julia --project=/workspaces/multiLanguage-weather-etl {JULIA_SUMMARY_SCRIPT_PATH}',
    cwd='/workspaces/multiLanguage-weather-etl'  # Set working directory
)



    # Chain tasks: table → dates → fetch → insert → export → julia_summary
    table = t_create_weather_table()
    dates = t_prepare_date_range()
    weather_data = t_fetch_weather_data(dates)
    insert = t_insert_weather_data(weather_data)
    export = t_export()
    table >> dates >> weather_data >> insert >> export >> julia_summary

weather_etl_full_pipeline_dag()
