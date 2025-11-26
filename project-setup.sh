#!/bin/bash
set -eu  # Exit on error, treat unset variables as error

# ===== PROJECT AUTO-SETUP SCRIPT: FOR CODESPACE OR LOCAL DEV =====
# This script automatically installs all dependencies and prepares the
# environment for Python (uv + Airflow 3.x), R (renv), and Julia.
# Run as root (the default in Codespaces at first).

PROJECT_HOME="/workspaces/multiLanguage-weather-etl"
AIRFLOW_HOME="$PROJECT_HOME/airflow"
DAGS_HOME="$PROJECT_HOME/dags"
USER_NAME="etluser"
USER_HOME="/home/$USER_NAME"

echo "🚀 Starting auto-setup for multi-language ETL project..."

# ---- SYSTEM LIBRARIES FOR R ENVIRONMENT ----
echo "📦 Installing required system dependencies for R graphics and ETL packages..."
apt-get update
apt-get install -y \\
    gdal-bin \\
    libgdal-dev \\
    libfontconfig1-dev \\
    libfreetype6-dev \\
    pandoc \\
    libharfbuzz-dev \\
    libfribidi-dev
echo "✅ R system libraries installed."

# ---- PROJECT USER AND DIRECTORY SETUP ----
# 1. Create user only if missing.
if ! id "$USER_NAME" &>/dev/null; then
    echo "👤 Creating user: $USER_NAME"
    useradd -m -s /bin/bash "$USER_NAME"
else
    echo "✅ User $USER_NAME already exists"
fi

# 2. Create directories
mkdir -p "$AIRFLOW_HOME"
mkdir -p "$DAGS_HOME"
chown -R "$USER_NAME:$USER_NAME" "$AIRFLOW_HOME" "$DAGS_HOME"

# 3. As the user: configure environment and initialize Airflow
su - "$USER_NAME" << 'EOF'
echo "🔧 Configuring environment as $USER..."
export AIRFLOW_HOME="$AIRFLOW_HOME"
export PROJECT_HOME="$PROJECT_HOME"

cd "$PROJECT_HOME" || exit 1

echo "🐍 Setting up Python environment with uv..."
# Install uv if not already available
if ! command -v uv &>/dev/null; then
    echo "Installing uv package manager..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Install Python dependencies using uv
echo "📦 Installing Python dependencies..."
uv pip install -r requirements.txt --system

echo "✈️  Installing Apache Airflow 3.x in local .venv..."
# Create local virtual environment for Airflow
python3 -m venv .venv
source .venv/bin/activate

# Install Airflow 3.x (adjust constraints URL if needed)
PYTHON_VERSION="$(python --version | cut -d" " -f 2 | cut -d. -f 1-2)"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-3.0.0/constraints-$PYTHON_VERSION.txt"
pip install "apache-airflow==3.0.0" --constraint "$CONSTRAINT_URL"
echo "✅ Airflow 3.x installed in .venv"

# Initialize Airflow DB
echo "🗃️  Initializing Airflow database..."
airflow db init || true  # Safe to re-run

# Create default admin user
airflow users create \\
    --username admin \\
    --firstname admin \\
    --lastname user \\
    --role Admin \\
    --email admin@example.com \\
    --password admin || echo "ℹ️  Admin user may already exist"

# Set dags_folder in airflow.cfg if needed
if [ -f "$AIRFLOW_HOME/airflow.cfg" ]; then
    grep -q "^dags_folder" "$AIRFLOW_HOME/airflow.cfg" || \\
        echo "dags_folder = $DAGS_HOME" >> "$AIRFLOW_HOME/airflow.cfg"
fi

# Symlink dags
ln -snf "$DAGS_HOME" "$AIRFLOW_HOME/dags"

echo "whoami: \$(whoami)"
echo "AIRFLOW_HOME: \$AIRFLOW_HOME"
echo "DAGS_HOME: $DAGS_HOME"

deactivate  # Exit Airflow venv

echo "📊 Setting up R environment with renv..."
# Initialize renv (restore packages from renv.lock)
if [ -f "$PROJECT_HOME/renv.lock" ]; then
    Rscript -e "renv::restore()"
    echo "✅ R environment restored via renv"
else
    echo "⚠️  No renv.lock found, skipping R package restore"
fi

echo "🔮 Setting up Julia environment..."
# Instantiate Julia packages from Project.toml
if [ -f "$PROJECT_HOME/Project.toml" ]; then
    julia --project=. -e 'using Pkg; Pkg.instantiate()'
    echo "✅ Julia packages instantiated"
else
    echo "⚠️  No Project.toml found, skipping Julia package setup"
fi

echo "✅ Setup complete. Now open a new bash tab, run su - $USER_NAME, and you're ready!"
EOF

echo "🎉 Auto-setup script finished successfully!"
