using CSV                      # For reading and writing CSV data
using DataFrames               # For DataFrame/table operations
using StatsBase                # For statistics like countmap (if needed)
using Dates                    # For working with dates and extracting years
using Chain                    # For clean, functional-style data pipelines

include("../config/constants.jl")
using .Constants               # For global constants, like lookup dicts

include("../helpers_jl/csv_from_txt_loader.jl")
using .CsvFromTxtLoader        # For project-specific raw weather data loading

"""
    main()

Main entry point for weather data processing and summary export.

Steps:
- Loads raw weather data using a custom Txt/CSV loader (must have columns: "date", "weather_code", "temp_max", "temp_min").
- Ensures "year" column is extracted from "date" (robust to both String and Date types).
- Adds human-readable weather descriptions via project lookup dictionary (Constants.WEATHERCODE_LOOKUP).
- Groups all data by year and weather type.
- Aggregates:
    * Frequency/count per group
    * Mean, min, max, std (standard deviation) for both max and min temperatures
- Prints summary statistics, schema, and first rows for inspection.
- Writes the result to a summary CSV and manifest for downstream R/Python use.
"""
function main()
    # 1. Load raw weather data (column names: date, weather_code, temp_max, temp_min)
    df_raw = CsvFromTxtLoader.load_csv_from_txt()

    # 2. Data wrangling and robust weather summary export
    grouped_df = @chain df_raw begin
        # Add year column from date, robust for String or Date types
        DataFrames.transform(_, :date => ByRow(x -> isa(x, Dates.Date) ? Dates.year(x) : Dates.year(Date(x, "yyyy-mm-dd"))) => :year)
        # Add human-readable weather description by code lookup
        DataFrames.transform(_, :weather_code => ByRow(x -> get(Constants.WEATHERCODE_LOOKUP, x, "Unknown")) => :weather_desc)
        # Group by year, weather code, and description
        DataFrames.groupby(_, [:year, :weather_code, :weather_desc])
        # Aggregate count and temperature statistics per group
        DataFrames.combine(_,
            nrow => :count,                           # Frequency per group
            :temp_max => mean => :mean_tempmax,
            :temp_max => minimum => :min_tempmax,
            :temp_max => maximum => :max_tempmax,
            :temp_max => std => :std_tempmax,
            :temp_min => mean => :mean_tempmin,
            :temp_min => minimum => :min_tempmin,
            :temp_min => maximum => :max_tempmin,
            :temp_min => std => :std_tempmin
        )
    end

    # 3. Inspection: print summary, schema, and first rows
    println("\n==== Weather Summary Data Overview ====")
    println("Rows: ", nrow(grouped_df), " | Columns: ", ncol(grouped_df))
    println("Columns: ", names(grouped_df))
    println("Summary statistics (DataFrames.describe):")
    println(describe(grouped_df))
    println("First 5 rows of summary output:")
    println(first(grouped_df, 5))
    println("\nEntire grouped summary example:")
    println(grouped_df)

    # 4. Export: save summary DataFrame to CSV, and write manifest (absolute path) for cross-language use
    export_dir = dirname(Constants.EXPORTED_CSV_PATH)
    if !isdir(export_dir)
        mkpath(export_dir)
        println("Created export directory: ", export_dir)
    end
    if !isdir(Constants.MANIFESTS_DIR)
        mkpath(Constants.MANIFESTS_DIR)
        println("Created manifests directory: ", Constants.MANIFESTS_DIR)
    end
    if isfile(Constants.EXPORTED_CSV_PATH)
        sz = filesize(Constants.EXPORTED_CSV_PATH)
        println("Warning: File already exists at $(Constants.EXPORTED_CSV_PATH). Current size: $(sz) bytes. It will be overwritten.")
    else
        println("No previous summary export detected at $(Constants.EXPORTED_CSV_PATH)—creating new export.")
    end
    CSV.write(Constants.EXPORTED_CSV_PATH, grouped_df)
    println("Exported grouped summary CSV at: ", Constants.EXPORTED_CSV_PATH)
    open(Constants.WEATHER_SUMMARY_CSV_MANIFEST, "w") do io
        println(io, abspath(Constants.EXPORTED_CSV_PATH))
    end
    println("Manifest file written for R/Python handoff at: ", Constants.WEATHER_SUMMARY_CSV_MANIFEST)
end

# Only run main() if this file is executed directly, not included
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
