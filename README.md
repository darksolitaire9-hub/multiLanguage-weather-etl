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
- Pro tip dispenser: Everything from uv instead of pip, to extension, to shell strictness.
- Reliable—once I checked (and validated) assumptions with real commands!

**Every config and fix here is both tried and AI-reviewed.**

---

## 🛠️ What the Devcontainer Now Delivers

- **Stable Ubuntu 22.04 base image** (proven, not “assumed”… see Issues below)
- **Python 3 managed by [uv](https://github.com/astral-sh/uv)** (pip removed after install)
- **R and Julia** full installs (robust, for Jupyter and scripts)
- **Apache Airflow** in persistent virtualenv with global CLI symlink
- **Jupyter kernels** for Python, R, and Julia (all auto-detected in VS Code)
- **Git, build-essential, curl, wget, etc** fully pre-installed
- **VS Code extensions** for Python, R, Julia, Jupyter, and GitHub/PR flow
- **Aggressive scripting:** strict mode, error on fail, apt cache cleanups, version verifications

---

## 🛠️ [2025-10-26] Automated Setup for Reproducible, Container-Native Development

**Update:**  
To make onboarding, re-building, and collaborating seamless, I’ve added an auto-setup script and standardized all project files, Airflow config, and pipelines to live entirely inside `/workspaces/multiLanguage-weather-etl`.

### Quick Setup & Usage

1. **Clone the Repo:**
    ```
    git clone https://github.com/[YOUR_NAME]/multiLanguage-weather-etl.git
    cd multiLanguage-weather-etl
    ```

2. **Run the automated setup script (as root):**
    ```
    bash project-setup.sh
    ```
    - This:
        - Creates a dedicated project user (`etluser`) and sets a password
        - Ensures all Airflow databases, config, DAGs, and logs are always self-contained in the repo tree
        - Prepares correct permissions and folder structure for container, Codespace, or direct Linux development

3. **Switch to the project user for all development:**
    ```
    su - etluser
    ```
    (Default password is `multiETL2025!` unless changed in the script.)

4. **Start Airflow and get building:**
    ```
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

**As always: Every step, error, and solution will be logged below as the project evolves.  
Open issues or add clarifying PRs if you find an edge case I missed!**

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
- **Issue:** Pip kept failing installs, virtual environments didn’t activate reliably, and dependency management was slow.
- **Resolution:**  
    - AI recommended switching to [uv](https://github.com/astral-sh/uv) for fast, clean Python package management.
    - Removed pip after installing uv to avoid cross-talk/confusion.

### 4. **Airflow CLI Not Found**
- **Issue:** Installing Airflow via uv/pip as user-only meant no `airflow` command in shell or scripts.
- **Resolution:**  
    - Installed Airflow in a dedicated venv (`/opt/airflow-venv`), then symlinked the CLI to `/usr/local/bin` for global access.

### 5. **VS Code Source Control/Extensions Not Auto-Syncing with CLI**
- **Issue:** After installing new CLI tools (like git), or changing user identity, VS Code extensions often didn’t "see" those changes right away.
- **Resolution:**  
    - **Reload the VS Code window:**  
        - Keyboard: `Ctrl+Shift+P`, then type/select “Reload Window”.
        - Or, refresh browser tab in Codespaces web.
    - Once reloaded, extensions and Source Control sidebar work as expected and detect all CLI/config changes.
- **Lesson:** In cloud/devcontainer environments, always reload after major installs or config tweaks for UI and shell to sync up.

### 6. **Git Commit Identity/Repo Auth**
- **Issue:** Commits would sometimes fail with “unknown author identity” or push would require GitHub login.
- **Resolution:**  
    - Set your global username/email using:
        ```
        git config --global user.name "darksolitaire9"
        git config --global user.email "darksolitaire9@gmail.com"
        ```
    - Check values at any time with:
        ```
        git config user.name
        git config user.email
        ```
    - Use these before the first commit, or VS Code/CLI may block or lose commit authorship.

---

## 💡 Developer Process: Tips & Learning Moments

- **Always confirm your environment** with:
    ```
    cat /etc/os-release
    ```
- **Check toolchain versions** after rebuild:
    ```
    python --version && uv --version && R --version && julia --version && airflow version && git --version
    ```
- **After CLI or config changes:**  
    Reload VS Code (`Ctrl+Shift+P` → “Reload Window”) to fix any Source Control/UI sync problems.
- **Set Git identity** before first commit—keeps history clean (see above).
- **Document every new issue and solution in this README**—future you will thank present you!

---

## 🚦 The Ongoing Experiment

This repo is more than just running code—it’s a documentation and learning experiment guided by curiosity, iteration, and AI support.  
As more data pipelines, bugs, or workflow improvements show up, you’ll find the journey, solutions, and libraries described here.

**If you want to learn, contribute, or just follow along—fork, PR, or just read and remix these lessons!**

---

_Created and updated as a log of curiosity-driven, AI-assisted discovery.  
This file will grow with every milestone, bug, and breakthrough._
