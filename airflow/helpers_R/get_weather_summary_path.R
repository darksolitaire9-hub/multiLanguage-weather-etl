# helpers/get_weather_summary_path.R

# --------------------------------------------------------------------------------
# Helper function to retrieve the path to the exported weather summary CSV file.
#
# Workflow:
#   - Sources constants.R from project root using here::here(), which defines
#     MANIFEST_PATH (location of manifest file, typically relative to project root).
#   - Manifest file should contain one line: absolute path to the weather summary CSV
#
# Function:
#   get_weather_summary_path(manifest_path = MANIFEST_PATH)
#
# Arguments:
#   manifest_path (character): Path to manifest file. Defaults to MANIFEST_PATH from config.
#
# Returns:
#   (character) Absolute path to weather_summary.csv as written by Julia pipeline.
#   Throws an error if manifest or referenced CSV does not exist.
#
# Usage (recommended for full reproducibility):
#   library(here)
#   source(here::here("airflow", "config", "constants.R"))
#   source(here::here("airflow", "helpers_R", "get_weather_summary_path.R"))
#   csv_path <- get_weather_summary_path()
# --------------------------------------------------------------------------------

library(here)
source(here::here("airflow", "config", "constants.R"))

get_weather_summary_path <- function(manifest_path = MANIFEST_PATH) {
  # Check that manifest file exists
  if (!file.exists(manifest_path)) {
    stop(paste("Manifest file does not exist:", manifest_path))
  }
  # Read lines from manifest (should be one line)
  lines <- readLines(manifest_path, warn=FALSE)
  if (length(lines) == 0) {
    stop("Manifest file is empty.")
  }
  path <- lines[1]
  # Check that referenced CSV file exists
  if (!file.exists(path)) {
    stop(paste("CSV file does not exist:", path))
  }
  # Return CSV path
  print(paste("Retrieved weather summary CSV path from manifest:", path))
  return(path)
}


