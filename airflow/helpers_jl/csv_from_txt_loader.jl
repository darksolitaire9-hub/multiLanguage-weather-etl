module CsvFromTxtLoader

using CSV
using DataFrames

include("path_utils.jl")
using .PathUtils

export load_csv_from_txt

"""
    load_csv_from_txt(config_dir::AbstractString=PathUtils.Constants.LOCATION_TO_CONFIG) -> Union{DataFrame, Nothing}

Finds the first .txt file in the config directory (using PathUtils), reads the CSV path inside, and loads the CSV as a DataFrame.

Returns `nothing` if:
  - The config directory doesn’t exist
  - No `.txt` file is found in the directory
  - The .txt file does not exist
  - The CSV file referenced inside the .txt does not exist

## Arguments
- `config_dir::AbstractString`: Directory in which to search for `.txt` files, defaults to project config path.

## Returns
- `DataFrame` on success
- `nothing` when missing files or errors

## Example
    using .CsvFromTxtLoader
    df = load_csv_from_txt()
    if isnothing(df)
        println("CSV file could not be loaded.")
    else
        println("Loaded DataFrame with size: ", size(df))
    end
"""
function load_csv_from_txt(config_dir::AbstractString=PathUtils.Constants.LOCATION_TO_CONFIG)
    # Defensive: Find the first TXT file (could be missing)
    txt_path = PathUtils.first_txt_file_fullpath(config_dir)
    if txt_path === nothing || !isfile(txt_path)
        return nothing
    end

    # Defensive: Read the CSV path from the TXT file (single line, stripped)
    csv_path = open(txt_path, "r") do io
        strip(readline(io))
    end

    # Defensive: Ensure the CSV file exists before trying to read it
    if !isfile(csv_path)
        return nothing
    end

    # Load and return DataFrame
    CSV.read(csv_path, DataFrame)
end

end # module




# ==== Example/Test code ====
# include("../helpers_jl/path_utils.jl")
# using .PathUtils    # Access first_txt_file_fullpath

# # Step 1: Find the TXT file containing the CSV path
# txt_path = first_txt_file_fullpath()   # Uses Constants.LOCATION_TO_CONFIG by default

# if txt_path !== nothing
#     println("Found TXT file at path: ", txt_path)
#     # Step 2: Read the CSV file path from the TXT file
#     csv_path = open(txt_path, "r") do io
#         strip(readline(io))
#     end
#     println("CSV path from TXT file: ", csv_path)

#     # Step 3: If the CSV exists, load it using CSV.jl and DataFrames.jl
#     if isfile(csv_path)
#         using CSV
#         using DataFrames
#         df = CSV.read(csv_path, DataFrame)
#         println("Loaded CSV! Size: ", size(df))
#         println("First five rows:")
#         println(first(df, 5))
#     else
#         println("CSV file not found at: ", csv_path)
#     end

# else
#     println("No TXT file found in config directory: ", PathUtils.Constants.LOCATION_TO_CONFIG)
# end
