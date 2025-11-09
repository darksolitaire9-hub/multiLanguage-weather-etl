module Constants

export LOCATION_TO_CONFIG, CONFIG_DIR, DATA_DIR, WEATHERCODE_LOOKUP

const CONFIG_DIR = "config"
const DATA_DIR = "data"

const LOCATION_TO_CONFIG = joinpath(@__DIR__, "..", CONFIG_DIR)

"""
WEATHERCODE_LOOKUP maps numerical weather codes (from Open-Meteo, WMO) to human-readable strings.

Reference:
- World Meteorological Organization (WMO): https://public.wmo.int/en/resources/code-tables
- Open-Meteo Codes: https://open-meteo.com/en/docs

Common codes:
    0    => "Clear"
    1    => "Partly cloudy"
    2    => "Cloudy"
    3    => "Overcast/Rain"
    51   => "Light Drizzle"
    53   => "Moderate Drizzle"
    61   => "Light Rain"
    63   => "Moderate Rain"
"""
const WEATHERCODE_LOOKUP = Dict(
    0 => "Clear",
    1 => "Partly cloudy",
    2 => "Cloudy",
    3 => "Overcast/Rain",
    51 => "Light Drizzle",
    53 => "Moderate Drizzle",
    61 => "Light Rain",
    63 => "Moderate Rain"
    # Add more codes as needed for your dataset
)

end # module
