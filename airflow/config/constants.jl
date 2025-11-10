module Constants

export LOCATION_TO_CONFIG, CONFIG_DIR, DATA_DIR, WEATHERCODE_LOOKUP

const CONFIG_DIR = "config"
const DATA_DIR = "data"

const LOCATION_TO_CONFIG = joinpath(@__DIR__, "..", CONFIG_DIR)

"""
WEATHERCODE_LOOKUP maps numerical weather codes (from Open-Meteo/WMO) to human-readable, 
UI-friendly weather type strings. 

This lookup covers all codes observed in the current dataset (as of November 2025), 
and the wording is adapted for user-facing interfaces (not just raw WMO labels).

## References:
- World Meteorological Organization (WMO): https://www.nodc.noaa.gov/archive/arc0021/0002199/1.1/data/0-data/HTML/WMO-CODE/WMO4677.HTM
- Open-Meteo Codes: https://open-meteo.com/en/docs

## Codes included:
    0   => "Clear"
    1   => "Partly cloudy"
    2   => "Cloudy"
    3   => "Overcast/Rain"
    51  => "Light Drizzle"
    53  => "Moderate Drizzle"
    55  => "Heavy Drizzle"
    61  => "Light Rain"
    63  => "Moderate Rain"
    65  => "Heavy Rain"

Add or update wording as needed to maintain consistency with frontend/user display.
"""
const WEATHERCODE_LOOKUP = Dict(
    0 => "Clear",
    1 => "Partly cloudy",
    2 => "Cloudy",
    3 => "Overcast/Rain",
    51 => "Light Drizzle",
    53 => "Moderate Drizzle",
    55 => "Heavy Drizzle",
    61 => "Light Rain",
    63 => "Moderate Rain",
    65 => "Heavy Rain",
)


end # module
