# Multi-Language Weather ETL Codespace: An Ongoing AI Learning & Building Journey

## 🌱 Project Vision & Curiosity

This project is a living experiment in **AI-empowered learning and hands-on technical discovery**.

**Main goal:** To see how far curiosity (and AI support) can take someone in mastering and building a multi-language, robust Codespaces environment for data engineering and ETL with Python, R, Julia, Airflow, and SQLite.

**This README is not final—it's my learning log, doc, and story-in-progress.**

---

## 🧠 AI as Mentor and Accelerator

From design choices to debugging, AI acted as:
- Mentor and rapid explainer of confusing docs, CLI errors, and best practices.
- Brainstorming/solution partner—suggesting alternatives and catching hidden issues.
- Pro tip dispenser: Everything from shell strictness to extensions.
- Reliable—once I checked (and validated) assumptions with real commands!
- *Note*: The switch to [uv](https://github.com/astral-sh/uv) for Python package management was a personal decision, not AI-recommended.

**Every config and fix here is both tried and AI-reviewed (unless otherwise noted as my own experiment).**

---

## 🛠️ What the Devcontainer Now Delivers

- **Stable Ubuntu 22.04 base image** (proven, not "assumed"… see Issues below)
- **Python 3 managed by [uv](https://github.com/astral-sh/uv)** (pip removed after install; uv was my personal choice for speed/reproducibility)
- **R and Julia** full installs (robust, for Jupyter and scripts)
- **Apache Airflow** in persistent virtualenv with global CLI symlink
- **Jupyter kernels** for Python, R, and Julia (all auto-detected in VS Code)
- **Git, build-essential, curl, wget, etc** fully pre-installed
- **ffmpeg installed and reproducible:** Command-line media toolkit now built in for ETL, video/audio/image preprocessing, and data pipeline demos—install verified and logged.
- **GitHub CLI (`gh`) for modern repo/workflow management:** Added for instant GitHub ops (PRs, issues, discussions) directly from Codespaces or terminal.
- **VS Code extensions** for Python, R, Julia, Jupyter, and GitHub/PR flow
- **Aggressive scripting:** strict mode, error on fail, apt cache cleanups, version verifications
- **.gitignore ensures reproducibility and clean repo:** Now ignores Airflow runtime, database files, ETL outputs, media artifacts (mp4, mp3, jpg, etc), Jupyter/R/Julia/Python build files, and temp/editor logs—ensures only clean, minimal, reproducible source and essential config is tracked.

---

## 🛠️ [2025-10-26] Automated Setup for Reproducible, Container-Native Development

**Update:**
To make onboarding, re-building, and collaborating seamless, I've added an auto-setup script and standardized all project files, Airflow config, and pipelines to live entirely inside `/workspaces/multiLanguage-weather-etl`.

### Quick Setup & Usage

1. **Clone the Repo:**

```bash
git clone https://github.com/[YOUR_NAME]/multiLanguage-weather-etl.git
cd multiLanguage-weather-etl
```

2. **Run the automated setup script (as root):**

```bash
bash project-setup.sh
```

   - This:
     - Creates a dedicated project user (`etluser`) and sets a password
     - Ensures all Airflow databases, config, DAGs, and logs are always self-contained in the repo tree
     - Prepares correct permissions and folder structure for container, Codespace, or direct Linux development

3. **Switch to the project user for all development:**

```bash
su - etluser
```

   (Default password is `multiETL2025!` unless changed in the script.)

4. **Start Airflow and get building:**

```bash
airflow db init
airflow webserver --port 8080
```

   (See setup troubleshooting below.)

5. **Codespaces/Dev Container:**
   - The script can auto-run on creation—see `.devcontainer/devcontainer.json` (`postCreateCommand`)
   - Everything—pipelines, Airflow state, configs, experiment notebooks—remains inside a single, versioned, reproducible repo directory

**Why this matters:**
- No more surprises about root-vs-user, home directory, or hidden state—if you can clone the repo, you can run the pipeline, reproduce results, or develop further.
- If future you—or a collaborator—hits an issue, the setup steps and troubleshooting will always match up with the README, script, and repo tree.

**As always: Every step, error, and solution will be logged below as the project evolves.**

---

## 🧩 Issues Faced So Far—and How We Solved Them

### 1. **Wrong Base OS: Alpine vs. Ubuntu**

- **Issue:** Codespaces often launched on Alpine Linux despite `ubuntu:22.04` config, causing failures for most installs, unexpected CLI behavior, and broken VS Code tooling.
- **Resolution:**
  - *Simple check was key*: Ran `cat /etc/os-release` in the CLI and instantly revealed "Alpine" (not Ubuntu).
  - Updated `.devcontainer/devcontainer.json` to ensure `"image": "ubuntu:22.04"`.
  - Only then did further config and package installs work reliably.
- **Lesson:** Never trust documentation or AI guesses about environment specifics—always check with `cat /etc/os-release` (or `lsb_release -a`) yourself!

### 2. **Missing Developer Tools**

- **Issue:** Alpine and minimal Ubuntu images often lacked `git`, `build-essential` and other baseline dev requirements.
- **Resolution:**
  - Script now explicitly installs `git`, `build-essential`, and companions before anything else.
  - Makes scripts and extensions run on first build.

### 3. **Python Package Management**

- **Issue:** Pip kept failing installs, virtual environments didn't activate reliably, and dependency management was slow.
- **Resolution:**
  - Switched to [uv](https://github.com/astral-sh/uv) for fast, clean Python package management—a personal choice after comparing options and learning about its speed and reproducibility benefits.
  - Removed pip after installing uv to avoid cross-talk/confusion.

### 4. **Airflow CLI Not Found**

- **Issue:** Installing Airflow via uv/pip as user-only meant no `airflow` command in shell or scripts.
- **Resolution:**
  - Installed Airflow in a dedicated venv (`/opt/airflow-venv`), then symlinked the CLI to `/usr/local/bin` for global access.

### 5. **VS Code Source Control/Extensions Not Auto-Syncing with CLI**

- **Issue:** After installing new CLI tools (like git), or changing user identity, VS Code extensions often didn't "see" those changes right away.
- **Resolution:**
  - **Reload the VS Code window:**
    - Keyboard: `Ctrl+Shift+P`, then type/select "Reload Window".
    - Or, refresh browser tab in Codespaces web.
  - Once reloaded, extensions and Source Control sidebar work as expected and detect all CLI/config changes.
- **Lesson:** In cloud/devcontainer environments, always reload after major installs or config tweaks for UI and shell to sync up.

### 6. **Git Commit Identity/Repo Auth**

- **Issue:** Commits would sometimes fail with "unknown author identity" or push would require GitHub login.
- **Resolution:**
  - Set your global username/email using:

```bash
git config --global user.name "darksolitaire9"
git config --global user.email "darksolitaire9@gmail.com"
```

  - Check values at any time with:

```bash
git config user.name
git config user.email
```

  - Use these before the first commit, or VS Code/CLI may block or lose commit authorship.

---

## 💡 Developer Process: Tips & Learning Moments

- **Always confirm your environment** with:

```bash
cat /etc/os-release
```

- **Check toolchain versions** after rebuild:

```bash
python --version && uv --version && R --version && julia --version && airflow version && git --version && ffmpeg -version && gh --version
```

- **After CLI or config changes:**
  Reload VS Code (`Ctrl+Shift+P` → "Reload Window") to fix any Source Control/UI sync problems.

- **Set Git identity** before first commit—keeps history clean (see above).

- **Document every new issue and solution in this README**—future you will thank present you!

- **Switch from pip to uv was my own research/experiment, not an AI suggestion.**

- **.gitignore ensures reproducibility and clean repo:**
  Ignores Airflow runtime, database files, ETL outputs, media artifacts (mp4, mp3, jpg, etc), Jupyter/R/Julia/Python build files, and temp/editor logs. Only source code, essential configs, and versioned DAGs are tracked.

---

## 🚦 The Ongoing Experiment

This repo is more than just running code—it's a documentation and learning experiment guided by curiosity, iteration, and AI support.

As more data pipelines, bugs, or workflow improvements show up, you'll find the journey, solutions, and libraries described here.

**If you want to learn, contribute, or just follow along—fork, PR, or just read and remix these lessons!**

---

*Created and updated as a log of curiosity-driven, AI-assisted discovery.*
*This file will grow with every milestone, bug, and breakthrough.*

---

## 🗓️ [2025-10-29] Update: ffmpeg, GitHub CLI, and .gitignore Improvements

**What changed today:**
- **ffmpeg** is now reproducibly installed in the devcontainer for programmatic media, audio, image, and ETL pipeline tasks.
- **GitHub CLI (`gh`)** is installed for seamless repo management directly in the terminal/Codespace.
- **.gitignore expanded:** Now robustly ignores Airflow dbs, logs, outputs, ETL and media artifacts, temp/editor system files, and all common multi-language project build/test artifacts.
- **Full rebuild tested:** All installs, verification steps, and CLI tools confirmed working after container rebuild.
- **Documentation/logging best practice:** This dated entry records the milestone and rationale for reproducibility and streamlined collaboration.

**Verification performed:**

```bash
ffmpeg -version
gh --version
ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=30 test_ffmpeg.mp4
ls -lh test_ffmpeg.mp4
```

*Note: The switch to uv for Python was my choice, not AI-suggested!*

---

## 🚀 [2025-10-30] Update: Python Dependency Flow, uv, and Geocode Utility

**Today's Milestone:**
- Setup and standardized Python dependency management using **uv** with a clean `pyproject.toml` (**no more pip!**)
- Added and tested the first pipeline helper: `airflow/helpers/geocode_utils.py` — fetches city coordinates via Open-Meteo's geocoding API (no API keys required)
- Improved reproducibility and cross-shell dev experience (especially for Codespaces users)

---

**How it works:**
- **Dependencies are declared and versioned** in `pyproject.toml` at the project root (currently: `requests`)
- **Project venv managed with uv:**

```bash
uv venv .venv
source .venv/bin/activate
uv pip install .
```

- **No more guessing/side installs:**
  Install all needed packages reliably with a single command; developers just follow the README/setup
- `.devcontainer/setup.sh` and devcontainer `postCreateCommand` can automate setup for newcomers/rebuilds

**What you can do now:**
- Write, run, and extend helpers/pipeline code without worrying about global vs project-specific Python
- Use the same workflow in both local dev, Codespaces, and containerized environments

**Example Usage:**

```python
from airflow.helpers.geocode_utils import get_city_coordinates
lat, lon = get_city_coordinates("Lisbon", country="PT")
print(lat, lon)  # e.g., 38.7071, -9.1355
```

**Commit Workflow:**
- Add/modify dependencies in `pyproject.toml`
- Commit changes first

```bash
git add pyproject.toml
git commit -m "update dependencies"
```

- Install using `uv pip install .` after pulling/merging changes

**Current Maintainer:**
- darksolitaire9+etl@gmail.com

---

**Summary:**
All contributors and future setups benefit from a **proven, versioned, and reproducible Python environment**, centered on uv—no more "works on my machine"!

The geocoding utility is the first step in your historical/forecast weather ETL pipeline.

Commit, pull, and build with confidence.

---

**Pipeline Helpers Expansion:**

**Today's Milestone:**
- Expanded pipeline helpers with robust API calls:
  - `geocode_utils.py`: Fetches latitude/longitude for any city via Open-Meteo's geocoding API. Now fully driven by config constants (`CITY_NAME`, `COUNTRY`), with clear error handling.
  - `weather_api.py`: Added to handle weather data API calls—retrieves weather info by coordinates for any date range.
- Centralized configuration:
  - Config file (`constants.py`) now holds all key parameters: city, country, start/end years, and base geocoding API URL.
  - Seamless updates for targets—just change config, no code edits needed.

---

**How the flow works:**
- Set all parameters for extraction in `config/constants.py`:

```python
CITY_NAME = "Lisbon"
COUNTRY = "PT"
START_YEAR = 2015
END_YEAR = 2025
BASE_URL = "https://geocoding-api.open-meteo.com/v1/search"
```

- Get coordinates via the helper:

```python
from airflow.helpers.geocode_utils import get_city_coordinates
lat, lon = get_city_coordinates(CITY_NAME, COUNTRY)
```

- Use those for weather API extraction:

```python
from airflow.helpers.weather_api import fetch_weather_json
for year in range(START_YEAR, END_YEAR + 1):
    start, end = f"{year}-01-01", f"{year}-12-31"
    data = fetch_weather_json(lat, lon, start, end)
    # process/save as needed
```

- All helpers use imported constants, no hardcoding—making pipelines reproducible and modular.

**Best Practices Applied:**
- Atomic, descriptive git commits for grouped logic (constants, helpers, new files).
- Helpers are generic and reusable; configs are pure constants.
- Project layout keeps logic, config, and workflow clearly separated.

**Summary:**
Project now supports parameter-driven geocoding and weather data ETL via open APIs—fully reproducible and ready for scalable automation. Just update config for instant new extractions!

*commit timestamp: 2025-10-30 16:34 WET*

---

## ⏩ ETL Pipeline Progress (As of 2025-11-06)

**Current workflow covers:**

1. **Extract:**
   - Fetches city coordinates from the geocoding API (`get_city_coordinates`)
   - Uses those coordinates to query daily historical weather data from the weather API

2. **Transform:**
   - Structures raw API JSON into normalized Python objects and lists
   - Each weather record is mapped to a date and defined variables

3. **Load:**
   - Inserts all normalized weather data into the local SQLite table (`weather_daily`)
   - Ensures unique records by date for full idempotency—safe to rerun any time
   - Exports the resulting table to CSV using Polars (chosen over pandas for speed, context manager support, and modern API)

---

**What's working right now:**

- All helpers use project config constants—no hardcoded paths, locations, or date ranges
- ETL jobs can be run standalone in any devcontainer/Codespace; always reproducible
- Directory creation and CSV outputs are robust (skipped if file exists and non-empty)
- Network errors and API failures are logged with clear messages; pipeline never silently fails or crashes on bad responses
- Pipeline is modular: each step (extract, transform, load/export) easily testable, replaceable, and designed for future automation/extension

---

## ✨ Daily Refactor & Language Insights — 2025-11-08

### 🚀 What We Did Today

- **Refactored Julia Config Utilities**
  - Standardized on `LOCATION_TO_CONFIG` as the source of truth for config pathing.
  - Removed the redundant `config_dir_exists`—now we use Julia's `isdir()` directly for directory checks.
  - Improved function signatures and documentation for clarity.

**Final Julia Script (Core Logic):**

```julia
include("../config/constants.jl")
using .Constants

"""
    first_txt_file(config_dir::AbstractString=Constants.LOCATION_TO_CONFIG) -> Union{String, Nothing}
    Finds all `.txt` files in the provided configuration directory, or returns nothing.
"""
function first_txt_file(config_dir::AbstractString=Constants.LOCATION_TO_CONFIG)
    if !isdir(config_dir)
        return nothing
    end
    files = readdir(config_dir)
    txt_files = filter(f -> endswith(f, ".txt"), files)
    return isempty(txt_files) ? nothing : txt_files
end

println("Testing config directory utilities on: ", LOCATION_TO_CONFIG)
txt_files = first_txt_file()

if txt_files !== nothing
    println("Found TXT file(s): ", txt_files)
elseif isdir(LOCATION_TO_CONFIG)
    println("No TXT files found in config directory.")
else
    println("Config directory does not exist at: ", LOCATION_TO_CONFIG)
end
```

- **Discussed Professional Script Patterns:**
  - **Julia:** Professional projects often use a `main()` function plus a guarded entry point (`if abspath(PROGRAM_FILE) == @__FILE__`).
  - **Python:** Uses `if __name__ == "__main__":` convention.
  - **R:** Most scripts run top-to-bottom, but you can optionally use a `main()` function at the end.

- **Best Practices for ETL Pipelines:**
  - Structure using a main function and an entry-point guard for clarity and maintainability in Julia and Python.

- **Coding Principle:**
  - Avoid redundant wrappers; use built-in library functions directly unless custom behavior is truly needed.

---

### 🌍 Language Differences Discovered

| Language | Indexing | Entry Point Pattern             | Script-style Supported |
|----------|----------|---------------------------------|-----------------------|
| Julia    | 1-based  | `main()` + entry guard          | Yes                   |
| Python   | 0-based  | `main()` + `__main__` guard     | Yes                   |
| R        | 1-based  | main function (optional)        | Yes                   |

- **R:** Scripts execute all lines by default unless structured with a main function.
- **Julia & Python:** Support robust entry guards, enabling clean modular code and reusability.

---

*Coded, reviewed, and summarized on **2025-11-08**.*

---

## 📆 Project Observations — November 9, 2025

### 🛡️ Defensive Programming: What We Learned

A major focus in our workflow has been **defensive programming**: designing code that anticipates missing files, absent directories, or irregular data—so the pipeline continues robustly even when things go wrong.

- **Every helper module checks for existence before processing files.**
- **Functions return `nothing` or clear messages on missing resources.**
- **The pipeline never crashes due to unexpected file system states; instead, steps are skipped or handled gracefully.**

This approach protects our ETL from real-world uncertainties—becoming essential for reliability in data engineering and automated workflows.

---

### 🚀 Why `--project=.` Is Critical in Julia Projects

Julia projects use a dedicated local environment (defined by `Project.toml` and `Manifest.toml` at your root) for package management and reproducibility.

**Running scripts directly (e.g., `julia script.jl`) uses the global Julia environment, which may lack required packages or the correct versions.**

#### Best Practice

Always run scripts with:

```bash
julia --project=. airflow/helpers_jl/csv_from_txt_loader.jl
```

- `--project=.` ensures the script uses your project's local environment.
- This guarantees package availability, reproducibility, and prevents hidden version conflicts.

#### What We Learned

Using `--project=.` for every script—from main analyses to helpers—keeps our workflow completely reproducible, robust, and collaboration-friendly.

---

## 📚 Project Overview

Cross-language ETL and weather data analysis pipeline using Julia, Python, and R.

Modular setup allows for data orchestration, summary CSV exports, and downstream analysis/visualization per language.

---

## 🗓️ Recent Additions (2025-11-11)

- **Added `airflow/config/constants.R`** – all R config variables/paths now centralized for maintainability.
- **Added `helpers_R/get_weather_summary_path.R`** – robust helper function for fetching and validating the path to the summary CSV produced by the pipeline.
  - Includes error checking for missing files, empty manifests, and invalid references.
  - Documents usage, workflow, and returns.
  - Supports default and custom manifest path.
- **Standardized folder structure** for configs, manifests, helpers, and analysis scripts.

---

## 📖 Example R Usage

```r
source('airflow/config/constants.R')
source('airflow/helpers_R/get_weather_summary_path.R')

# Retrieve validated weather summary CSV path
csv_path <- get_weather_summary_path()

# Load summary CSV into a data.frame
df <- read.csv(csv_path)
```

---

## ⚙️ How to Run R Helper in Batch

From project root:

```bash
Rscript airflow/helpers_R/get_weather_summary_path.R
```

---

## 📁 Folder Structure

```
multiLanguage-weather-etl/
├── airflow/config/constants.R
├── airflow/helpers_R/get_weather_summary_path.R
├── manifests/latest_weather_summary_csv_path.txt
```

---

## 📝 Notes

- Locale warnings during R batch execution are harmless for ASCII/English workflows.
- For multi-language functionality, analogous helpers/configs exist for Julia and Python.
