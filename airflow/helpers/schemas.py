# airflow/helpers/schemas.py
from typing import List, Optional
from pydantic import BaseModel, Field

class DailyData(BaseModel):
    """
    Represents the daily weather variables returned by the Open-Meteo API.
    
    Fields are Optional to handle cases where:
    1. A specific variable was not requested.
    2. Data is missing/null from the provider for a given location.
    """
    time: List[str] = Field(
        ..., 
        description="List of dates in YYYY-MM-DD format. Corresponds to the daily intervals."
    )
    
    temperature_2m_max: Optional[List[float]] = Field(
        None, 
        description="Maximum daily air temperature at 2 meters above ground (°C)."
    )
    
    temperature_2m_min: Optional[List[float]] = Field(
        None, 
        description="Minimum daily air temperature at 2 meters above ground (°C)."
    )
    
    weather_code: Optional[List[float]] = Field(
        None, 
        description="WMO weather code indicating the general weather condition (e.g., Rain, Sun)."
    )
    
    precipitation_sum: Optional[List[float]] = Field(
        None, 
        description="Sum of daily precipitation (rain, showers, snow) in millimeters."
    )

    class Config:
        # Ignores extra fields returned by the API that are not defined here.
        # Prevents crashes if the API adds new features (e.g., wind_speed) in the future.
        extra = "ignore" 

class WeatherResponse(BaseModel):
    """
    Top-level response model for the Open-Meteo Historical Weather API.
    Validates the metadata and the nested daily data payload.
    """
    latitude: float = Field(..., description="Latitude of the location (WGS84).")
    longitude: float = Field(..., description="Longitude of the location (WGS84).")
    timezone: str = Field(..., description="Timezone identifier (e.g., 'Europe/Lisbon').")
    
    daily: DailyData = Field(..., description="Nested object containing the daily weather series.")
