using CSV                      # CSV.write, CSV read/write functionality
using DataFrames               # DataFrame operations: transform, groupby, combine, nrow, ncol, names, describe, first
using StatsBase                # countmap for code distribution
using Dates                    # Date parsing and year extraction
using Chain                    # @chain macro for pipeline syntax

include("../config/constants.jl")
using .Constants               # Constants: paths, WEATHERCODE_LOOKUP dictionary

include("../helpers_jl/csv_from_txt_loader.jl")
using .CsvFromTxtLoader        # Project-specific weather loader

"""
    main()

Main entry point for weather data analysis and export.

Pipeline steps and library notes:
- Loads weather data with custom CsvFromTxtLoader (local include)
- Uses `transform` (DataFrames.jl) to add `year` column: parses string to Date (Dates.jl), extracts integer year.
- Adds `weather_desc` column using project-wide lookup (Constants, base Julia `get`)
- Groups/aggregates with `groupby` and `combine` (DataFrames.jl) for mean calculation.
- Describes, prints and writes with DataFrames.jl and CSV.jl
- Robust output and workflow handoff using manifest written with base Julia IO.

Implementation uses Chain.jl (`@chain`) for readable, functional-style pipelines.
"""
function main()
    # 1. Load raw weather data as a DataFrame (CsvFromTxtLoader is project-specific)
    df_raw = CsvFromTxtLoader.load_csv_from_txt()

    # 2. Functional pipeline (Chain.jl for piping)
    grouped_df = @chain df_raw begin
        DataFrames.transform(_, :date => ByRow(x -> isa(x, Dates.Date) ? Dates.year(x) : Dates.year(Dates.Date(x, "yyyy-mm-dd"))) => :year)
        DataFrames.transform(_, :weather_code => ByRow(x -> get(Constants.WEATHERCODE_LOOKUP, x, "Unknown")) => :weather_desc)
        DataFrames.groupby(_, [:year, :weather_code, :weather_desc])
        DataFrames.combine(_, :temp_max => mean => :mean_tempmax,
                              :temp_min => mean => :mean_tempmin)
    end

    # 3. Print/summary (DataFrames methods)
    println("\n==== Labeled/Aggregated Data Overview ====")
    println("Number of rows: ", DataFrames.nrow(grouped_df))
    println("Number of columns: ", DataFrames.ncol(grouped_df))
    println("Column names: ", DataFrames.names(grouped_df))
    println("Summary statistics (describe):")
    println(DataFrames.describe(grouped_df))
    println("First 5 rows:")
    println(DataFrames.first(grouped_df, 5))
    println("\nMean tempmax and tempmin by year and weather_code:")
    println(grouped_df)

    # 4. Export & manifest logic (base Julia, CSV.jl, with DataFrames output)
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
        println("No previous export file detected at $(Constants.EXPORTED_CSV_PATH)—creating new export.")
    end
    CSV.write(Constants.EXPORTED_CSV_PATH, grouped_df)
    println("Exported summary CSV for R/Python analysis at: ", Constants.EXPORTED_CSV_PATH)
    open(Constants.WEATHER_SUMMARY_CSV_MANIFEST, "w") do io
        println(io, abspath(Constants.EXPORTED_CSV_PATH))
    end
    println("Manifest file written for downstream consumption: ", Constants.WEATHER_SUMMARY_CSV_MANIFEST)
end

# Standard Julia script guard—invokes main() only on direct script run.
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
