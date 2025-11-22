# Load robust file paths and all required packages
library(here)          # Robust file paths for cross-platform use
library(ggplot2)       # Visualization
library(dplyr)         # Data wrangling
library(viridisLite)   # Color palettes for plots
library(gganimate)     # For animated plots
library(av)            # MP4/video export via ffmpeg

# Source configuration and helper scripts (adjust paths as necessary)
source(here::here("airflow", "config", "constants.R"))     # Project constants
source(here::here("airflow", "helpers_R", "load_weather_summary_csv.R")) # Data loading helper

# Load the weather summary data with your custom loader
weather_data <- load_weather_summary_csv()

# Inspect the first few rows—good practice before plotting
print(head(weather_data))

# Build animated plot with historical context and dynamic subtitle
plot_shadow <- weather_data %>%
  ggplot(
    aes(
      x = factor(year),         # Treat years as categories for the bar chart
      y = count,                # Frequency/count of weather type
      fill = weather_desc,      # Color bars by weather type
      group = weather_desc      # Group by desc for animation and shadows
    )
  ) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.9) +     # Bars with 90% opaque
  shadow_mark(alpha = 0.2, colour = "grey70") +                      # Previous years shown faintly
  labs(
    x = "Year",
    y = "Frequency",
    fill = "Weather Type",
    title = "Frequency of Weather Types Over the Years",
    subtitle = "Year: {closest_state}"     # Subtitle dynamically updates to current year
  ) +
  scale_fill_viridis_d(option = "plasma") +                          # Nice color palette
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 14),
    axis.text = element_text(size = 10),
    legend.position = "right"
  ) +
  transition_states(
    year, 
    transition_length = 2,   # Number of frames for transition animation
    state_length = 1         # Number of frames to hold each year’s bars
  ) +
  ease_aes('cubic-in-out')   # Smoothen frame-to-frame transitions

# Set up output directory and file
media_dir <- here::here("airflow", "visualizations", "media")
output_path <- file.path(media_dir, "weather_animation_shadow.mp4")

# Abort if output directory exists
if (dir.exists(media_dir)) {
  stop(paste("Directory", media_dir, "already exists - Aborting to prevent overwrite."))
}

# Otherwise, create the directory
dir.create(media_dir, recursive = TRUE)

# Abort if output file exists
if (file.exists(output_path)) {
  stop(paste("File already exists at", output_path, "- Aborting to prevent overwrite."))
}

# Save animation as MP4 video in airflow/visualizations/media
anim_save(
  filename = output_path,
  animation = plot_shadow,
  renderer = av_renderer(),
  nframes = 100,
  fps = 10,
  width = 800,
  height = 600
)

cat("Animation saved as airflow/visualizations/media/weather_animation_shadow.mp4\n")
