# config/constants.jl

module Constants

export LOCATION_TO_CONFIG, CONFIG_DIR, DATA_DIR # etc.

const CONFIG_DIR = "config"
const DATA_DIR = "data"
const LOCATION_TO_CONFIG = joinpath(@__DIR__, "..", CONFIG_DIR)

end
