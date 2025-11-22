# Project constants and helpers
from ..config.constants import DB_PATH
from ..helpers.db_utils import create_weather_table
from ..helpers.db_loader import insert_weather_data
from ..helpers.weather_api import fetch_weather_data
from ..helpers.date_utils import get_interval_start_to_end_dates
from ..config.constants import (
    CITY_NAME, COUNTRY, WEATHER_API_URL,
    START_YEAR, NUM_YEARS, DIRECTION, DAILY_VARIABLES
)

# Airflow core imports
from airflow.decorators import dag, task
from datetime import datetime


@dag(
    dag_id='weather_etl_by_city_dag',
    schedule_interval='@daily',
    start_date=datetime(2025, 11, 22),
    catchup=False,
    tags=['weather', 'etl', 'city']
)

def weather_etl_by_city_dag():

    @task(task_id='create_weather_table_task')
    def create_weather_table_task():
        create_weather_table(DB_PATH)
        print(f"Ensured weather table exists at {DB_PATH}")



weather_etl_by_city_dag()