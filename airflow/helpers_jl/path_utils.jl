include("../config/constants.jl")
using .Constants

"""
    first_txt_file_fullpath(config_dir::AbstractString=Constants.LOCATION_TO_CONFIG) -> Union{String, Nothing}

Finds the *first* `.txt` file in the provided configuration directory and returns its full absolute path
as a string (ready for opening/reading). Returns `nothing` if no `.txt` file is found or if the directory does not exist.

## Example
    txt_path = first_txt_file_fullpath()  # uses LOCATION_TO_CONFIG by default
    if txt_path !== nothing
        println("Found TXT file at path: ", txt_path)
        # open(txt_path) do io ...
    end

# Arguments
- config_dir::AbstractString: Directory in which to search for `.txt` files. Defaults to LOCATION_TO_CONFIG.
# Returns
- String: Full path of the first `.txt` file found in the directory.
- nothing: If directory is missing or no `.txt` file exists.
"""
function first_txt_file_fullpath(config_dir::AbstractString=Constants.LOCATION_TO_CONFIG)
    if !isdir(config_dir)
        return nothing
    end
    files = readdir(config_dir)
    txt_files = filter(f -> endswith(f, ".txt"), files)
    return isempty(txt_files) ? nothing : joinpath(config_dir, txt_files[1])
end

# Example / Test
println("Testing config directory utilities on: ", LOCATION_TO_CONFIG)
txt_path = first_txt_file_fullpath()  # Uses LOCATION_TO_CONFIG by default

if txt_path !== nothing
    println("Found TXT file at path: ", txt_path)
elseif isdir(LOCATION_TO_CONFIG)
    println("No TXT files found in config directory.")
else
    println("Config directory does not exist at: ", LOCATION_TO_CONFIG)
end
