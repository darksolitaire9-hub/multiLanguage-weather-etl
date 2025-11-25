module Constants

export LOCATION_TO_CONFIG, CONFIG_DIR, DATA_DIR, WEATHERCODE_LOOKUP, EXPORTED_CSV_DIR, SUMMARY_CSV_NAME, EXPORTED_CSV_PATH, MANIFESTS_DIR, WEATHER_SUMMARY_CSV_MANIFEST

const CONFIG_DIR = "config"
const DATA_DIR = "data"

# Absolute path to configuration directory, resolved relative to this file's location.
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
Export Pathing for summary CSV workflow and inter-language handoff (Julia/R/Python/etc).

EXPORTED_CSV_DIR:
    - Absolute path to the directory for storing exported CSV files (e.g., for R visualizations, reporting).
    - Always resolved relative to this project's root ("data/exported_csvs" folder).

SUMMARY_CSV_NAME:
    - File name for the summary analytics CSV export.
    - Change as needed for versioning, reporting, or task-specific exports.

EXPORTED_CSV_PATH:
    - Absolute path for the main analytics summary CSV file, built from above directory and filename.
    - Downstream tools should reference this, or read its manifest if written for workflow handoff.

MANIFESTS_DIR:
    - Project-level directory (outside data/), dedicated to manifest files for workflow automation and handoff across scripts/languages.
    - Keeps manifest pointers organized, discoverable, and decoupled from data outputs.

WEATHER_SUMMARY_CSV_MANIFEST:
    - Path to manifest file indicating the latest summary CSV export.
    - Always write/export this manifest immediately after each new summary CSV is generated.
    - R, Python, or other tools read this manifest dynamically to obtain the location of the most recent analytics output.
    - Example: "manifests/latest_weather_summary_csv_path.txt"

Best practices:
- Always check/ensure export directories and manifest directories exist before writing.
- Export a manifest file with EXPORTED_CSV_PATH for reproducibility and cross-language workflow coordination.
- Adapt naming, codebook, and directory conventions if project structure or workflow changes.
"""
const EXPORTED_CSV_DIR = joinpath(@__DIR__, "..", "..", "data", "exported_csvs")
const SUMMARY_CSV_NAME = "weather_summary_for_r.csv"
const EXPORTED_CSV_PATH = joinpath(EXPORTED_CSV_DIR, SUMMARY_CSV_NAME)

const MANIFESTS_DIR = joinpath(@__DIR__, "..", "..", "manifests")
const WEATHER_SUMMARY_CSV_MANIFEST = joinpath(MANIFESTS_DIR, "latest_weather_summary_csv_path.txt")

end # module
