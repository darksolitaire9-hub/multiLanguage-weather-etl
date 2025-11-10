using CSV
using DataFrames
using StatsBase

include("../config/constants.jl")
using .Constants     # Access Constants.WEATHERCODE_LOOKUP

include("../helpers_jl/csv_from_txt_loader.jl")   
using .CsvFromTxtLoader     # Access load_csv_from_txt

"""
    main()

Main entry point for weather data analysis.
Loads, checks, labels, and prints summaries of weather data.
"""
function main()
    # 1. Load the original DataFrame (raw data)
    df_raw = CsvFromTxtLoader.load_csv_from_txt()

    # 2. Data overview (explicit, qualified method calls)
    println("==== Data Overview ====")
    println("Number of rows: ", DataFrames.nrow(df_raw))
    println("Number of columns: ", DataFrames.ncol(df_raw))
    println("Column names: ", DataFrames.names(df_raw))
    println("Summary statistics:")
    println(DataFrames.describe(df_raw))
    println("Weather code distribution: ", StatsBase.countmap(df_raw.weather_code))

    # 3. Copy original for safe transformation
    weather_labeled_df = deepcopy(df_raw)

    # 4. Add human-readable weather description column
    weather_labeled_df.weather_desc = get.(Ref(Constants.WEATHERCODE_LOOKUP), weather_labeled_df.weather_code, "Unknown")

    # 5. Data overview after transformation
    println("\n==== Labeled Data Overview ====")
    println("Number of rows: ", DataFrames.nrow(weather_labeled_df))
    println("Number of columns: ", DataFrames.ncol(weather_labeled_df))
    println("Column names: ", DataFrames.names(weather_labeled_df))
    println("Summary statistics (labeled):")
    println(DataFrames.describe(weather_labeled_df))

    # 6. Show first few rows
    println("\nFirst 5 rows of labeled DataFrame:")
    println(DataFrames.first(weather_labeled_df, 5))
    
    # 7. Aggregation: mean of both tempmax and tempmin by weather_code
    grouped = DataFrames.combine(
        DataFrames.groupby(weather_labeled_df, [:weather_code, :weather_desc]),
        :temp_max => mean => :mean_tempmax,
        :temp_min => mean => :mean_tempmin
    )
    println("\nMean tempmax and tempmin by weather_code:")
    println(grouped)

    # 8. Ensure export directory exists
    outdir = dirname(Constants.EXPORTED_CSV_PATH)
    if !isdir(outdir)
        mkpath(outdir)
        println("Created export directory: ", outdir)
    end

    # 9. Export the grouped summary DataFrame to CSV for R visualization
    if isfile(Constants.EXPORTED_CSV_PATH)
        sz = filesize(Constants.EXPORTED_CSV_PATH)
        println("Warning: File already exists at $(Constants.EXPORTED_CSV_PATH). Current size: $(sz) bytes. It will be overwritten.")
    else
        println("No previous export file detected at $(Constants.EXPORTED_CSV_PATH)—creating new export.")
    end

    CSV.write(Constants.EXPORTED_CSV_PATH, grouped)
    println("Exported summary CSV for R visualization at: ", Constants.EXPORTED_CSV_PATH)

    
end

# Recommended Julia main script guard
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
