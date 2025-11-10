module Constants

export LOCATION_TO_CONFIG, CONFIG_DIR, DATA_DIR, WEATHERCODE_LOOKUP, EXPORTED_CSV_DIR, SUMMARY_CSV_NAME, EXPORTED_CSV_PATH

const CONFIG_DIR = "config"
const DATA_DIR = "data"

# Absolute path to configuration directory, resolved safely from file location.
const LOCATION_TO_CONFIG = joinpath(@__DIR__, "..", CONFIG_DIR)

"""
WEATHERCODE_LOOKUP maps numerical weather codes (from Open-Meteo/WMO) to human-readable, 
UI-friendly weather type strings.

- Covers all codes observed in the current dataset (as of November 2025).
- Wording is adapted for frontend display (not just raw WMO labels).
- Add or update entries as your data evolves or UI/design conventions change.

References:
- World Meteorological Organization (WMO): https://www.nodc.noaa.gov/archive/arc0021/0002199/1.1/data/0-data/HTML/WMO-CODE/WMO4677.HTM
- Open-Meteo Codes: https://open-meteo.com/en/docs
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

"""
Export Pathing for CSV workflow and inter-language handoff (Julia/R/Python/etc).

EXPORTED_CSV_DIR:
    - Absolute path to the directory for storing exported CSV files (e.g., for R visualizations, reporting).
    - Always resolved relative to this project's root ("data/exported_csvs" folder).

SUMMARY_CSV_NAME:
    - File name for the summary analytics CSV export.
    - Change as needed for versioning, reporting, or task-specific exports.

EXPORTED_CSV_PATH:
    - Absolute path for the main analytics summary CSV file, built from above directory and filename.
    - Downstream tools should reference this, or read its manifest if written for workflow handoff.
    - Pipeline can write a manifest file with this path after export (e.g., "latest_export_path.txt" in exported_csvs), enabling programmatic lookup from R/Python/etc.

Best practice: 
- Always check/ensure export directories exist before analysis writes.
- Export a manifest text file with EXPORTED_CSV_PATH for reproducibility and cross-language workflow coordination.
"""
const EXPORTED_CSV_DIR = joinpath(@__DIR__, "..", "..", "data", "exported_csvs")
const SUMMARY_CSV_NAME = "weather_summary_for_r.csv"
const EXPORTED_CSV_PATH = joinpath(EXPORTED_CSV_DIR, SUMMARY_CSV_NAME)

end # module
