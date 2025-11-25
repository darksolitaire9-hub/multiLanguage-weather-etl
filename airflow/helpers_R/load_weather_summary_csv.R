# airflow/helpers_R/load_weather_summary_csv.R

# ----------------------------------------------------------------------
# Helper to load the weather summary CSV using path from manifest (robust)
#
# Usage:
#   library(here)
#   source(here::here("airflow", "config", "constants.R"))
#   source(here::here("airflow", "helpers_R", "get_weather_summary_path.R"))
#   source(here::here("airflow", "helpers_R", "load_weather_summary_csv.R"))
#   df <- load_weather_summary_csv()
#   print(head(df))
# ----------------------------------------------------------------------

library(here)
source(here::here("airflow", "config", "constants.R"))
source(here::here("airflow", "helpers_R", "get_weather_summary_path.R"))

load_weather_summary_csv <- function(manifest_path = MANIFEST_PATH, ...) {
  csv_path <- get_weather_summary_path(manifest_path)
  # Robust check: file must exist at path
  if (!file.exists(csv_path)) {
    stop(paste("CSV file does not exist at the path:", csv_path))
  }
  # Try to load the CSV, with error handling
  df <- tryCatch(
    {
      read.csv(csv_path, ...)
    },
    error = function(e) {
      stop(paste("Failed to read CSV at", csv_path, ":", e$message))
    }
  )
  print(paste("Successfully loaded weather summary CSV from:", csv_path))
  return(df)
}

