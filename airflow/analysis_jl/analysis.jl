using CSV                       # For DataFrame <-> CSV export
using DataFrames                # For tabular data manipulation
using StatsBase                 # For statistical analysis

include("../config/constants.jl")
using .Constants                # Access all project-wide path and data constants

include("../helpers_jl/csv_from_txt_loader.jl")
using .CsvFromTxtLoader         # Access CsvFromTxtLoader.load_csv_from_txt

"""
    main()

Main entry point for weather data analysis and export.

- Loads weather data from standardized pipeline text/CSV sources.
- Prints explicit data overviews and summary statistics.
- Adds UI-consistent weather descriptions using WEATHERCODE_LOOKUP mapping.
- Groups and aggregates weather statistics: mean temperature max/min by weather code and description.
- Exports the summary DataFrame to a configurable CSV location for downstream use (e.g., R, Python).
- Writes a manifest file **with absolute path** to the latest summary export for robust cross-language workflow handoff.

All file/directory and manifest logic is robust to missing paths and supports reproducible pipelines.
"""
function main()
    # 1. Load raw weather data as a DataFrame
    df_raw = CsvFromTxtLoader.load_csv_from_txt()

    # 2. Data overview and statistics (qualified calls)
    println("==== Data Overview ====")
    println("Number of rows: ", DataFrames.nrow(df_raw))
    println("Number of columns: ", DataFrames.ncol(df_raw))
    println("Column names: ", DataFrames.names(df_raw))
    println("Summary statistics:")
    println(DataFrames.describe(df_raw))
    println("Weather code distribution: ", StatsBase.countmap(df_raw.weather_code))

    # 3. Copy original DataFrame for transformations (avoid mutating raw)
    weather_labeled_df = DataFrames.deepcopy(df_raw)

    # 4. Add human-readable weather description using WEATHERCODE_LOOKUP mapping
    weather_labeled_df.weather_desc = get.(Ref(Constants.WEATHERCODE_LOOKUP), weather_labeled_df.weather_code, "Unknown")

    # 5. Data overview after labeling
    println("\n==== Labeled Data Overview ====")
    println("Number of rows: ", DataFrames.nrow(weather_labeled_df))
    println("Number of columns: ", DataFrames.ncol(weather_labeled_df))
    println("Column names: ", DataFrames.names(weather_labeled_df))
    println("Summary statistics (labeled):")
    println(DataFrames.describe(weather_labeled_df))

    # 6. Display first few labeled rows
    println("\nFirst 5 rows of labeled DataFrame:")
    println(DataFrames.first(weather_labeled_df, 5))

    # 7. Aggregation: mean of temp_max and temp_min by weather code/description
    grouped = DataFrames.combine(
        DataFrames.groupby(weather_labeled_df, [:weather_code, :weather_desc]),
        :temp_max => mean => :mean_tempmax,
        :temp_min => mean => :mean_tempmin
    )
    println("\nMean tempmax and tempmin by weather_code:")
    println(grouped)

    # 8. Ensure export and manifest directories exist
    export_dir = dirname(Constants.EXPORTED_CSV_PATH)
    if !isdir(export_dir)
        mkpath(export_dir)
        println("Created export directory: ", export_dir)
    end
    if !isdir(Constants.MANIFESTS_DIR)
        mkpath(Constants.MANIFESTS_DIR)
        println("Created manifests directory: ", Constants.MANIFESTS_DIR)
    end

    # 9. Export file existence check for clarity/logging
    if isfile(Constants.EXPORTED_CSV_PATH)
        sz = filesize(Constants.EXPORTED_CSV_PATH)
        println("Warning: File already exists at $(Constants.EXPORTED_CSV_PATH). Current size: $(sz) bytes. It will be overwritten.")
    else
        println("No previous export file detected at $(Constants.EXPORTED_CSV_PATH)—creating new export.")
    end

    # 10. Export the grouped summary DataFrame to CSV for multi-language analysis
    CSV.write(Constants.EXPORTED_CSV_PATH, grouped)
    println("Exported summary CSV for R/Python analysis at: ", Constants.EXPORTED_CSV_PATH)

    # 11. Write manifest file in manifests/ with the **absolute path** for robust workflow handoff
    open(Constants.WEATHER_SUMMARY_CSV_MANIFEST, "w") do io
        println(io, abspath(Constants.EXPORTED_CSV_PATH))
    end
    println("Manifest file written for downstream consumption: ", Constants.WEATHER_SUMMARY_CSV_MANIFEST)
end

# Julia script guard: ensure main runs only if invoked directly (not via include)
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
