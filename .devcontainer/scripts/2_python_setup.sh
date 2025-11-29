#!/bin/bash
set -e

echo "🐍 [2/3] Setting up Python Environment..."

# ------------------------------------------------------------------
# 1. Install uv & Sync Dependencies (The "Download" Phase)
# ------------------------------------------------------------------

# Install uv if missing
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Verify pyproject.toml exists
if [ ! -f "pyproject.toml" ]; then
    echo "❌ Error: pyproject.toml not found in project root"
    exit 1
fi

# Sync dependencies (Downloads Airflow & others)
echo "Syncing Python dependencies..."
uv sync

# ------------------------------------------------------------------
# 2. Verify Installation
# ------------------------------------------------------------------
echo "Verifying Airflow installation..."
if ! uv run python -c "import airflow" &> /dev/null; then
    echo "❌ Error: Airflow was not installed correctly."
    exit 1
fi
echo "✅ Airflow installed successfully."

# ------------------------------------------------------------------
# 3. Define & Persist Environment Variables
# ------------------------------------------------------------------
CURRENT_DIR="$(pwd)"
TARGET_AIRFLOW_HOME="${CURRENT_DIR}/airflow"

echo "📝 Configuring environment variables..."

# Function to append to .bashrc safely
append_to_bashrc() {
    local LINE="$1"
    local FILE="$HOME/.bashrc"
    if ! grep -Fxq "$LINE" "$FILE"; then
        echo "$LINE" >> "$FILE"
    fi
}

# Define the exports
EXPORT_HOME="export AIRFLOW_HOME=\"$TARGET_AIRFLOW_HOME\""
# Note: We refer to $AIRFLOW_HOME inside the second string so it stays dynamic
EXPORT_PYTHONPATH="export PYTHONPATH=\"\$AIRFLOW_HOME:\$PYTHONPATH\""
EXPORT_NO_EXAMPLES="export AIRFLOW__CORE__LOAD_EXAMPLES=False"

# Apply them to the CURRENT script execution so we can run cleanup immediately
export AIRFLOW_HOME="$TARGET_AIRFLOW_HOME"
export PYTHONPATH="$AIRFLOW_HOME:$PYTHONPATH"
export AIRFLOW__CORE__LOAD_EXAMPLES=False

# Persist them to .bashrc for FUTURE user sessions
append_to_bashrc "$EXPORT_HOME"
append_to_bashrc "$EXPORT_PYTHONPATH"
append_to_bashrc "$EXPORT_NO_EXAMPLES"

echo "   Variables exported and saved to ~/.bashrc"

# ------------------------------------------------------------------
# 4. Cleanup (Remove Examples)
# ------------------------------------------------------------------
echo "🧹 Resetting Database to remove examples..."
# Now that AIRFLOW_HOME is set for this session, this command works on the right DB
uv run airflow db reset -y > /dev/null 2>&1

# ------------------------------------------------------------------
# 5. Final User Instructions
# ------------------------------------------------------------------
echo ""
echo "✅ Setup Complete."
echo "=================================================================="
echo "⚠️  IMPORTANT: ACTIVATE YOUR ENVIRONMENT"
echo "=================================================================="
echo "The setup is done, but your current shell doesn't have the variables yet."
echo ""
echo "👉 Run this command to activate everything:"
echo ""
echo "    source ~/.bashrc && source .venv/bin/activate"
echo ""
echo "👉 Then start Airflow:"
echo ""
echo "    airflow standalone"
echo ""
echo "=================================================================="
