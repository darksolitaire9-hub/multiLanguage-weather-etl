#!/bin/bash
set -e

echo "🐍 [2/3] Setting up Python Environment..."

# ------------------------------------------------------------------
# 1. Install uv (Python Package Manager)
# ------------------------------------------------------------------
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# ------------------------------------------------------------------
# 2. Sync Dependencies
# ------------------------------------------------------------------
if [ ! -f "pyproject.toml" ]; then
    echo "❌ Error: pyproject.toml not found in project root"
    exit 1
fi
echo "Syncing Python dependencies..."
uv sync

# ------------------------------------------------------------------
# 3. Configure Shell Environment (Robust Function Approach)
# ------------------------------------------------------------------
# We define a function 'setup_airflow_env' in .bashrc that:
#   1. Sets the correct Environment Variables (AIRFLOW_HOME, PYTHONPATH)
#   2. Activates the Virtual Environment (.venv)
#   3. Is called automatically when a new terminal opens
# ------------------------------------------------------------------

CURRENT_DIR=$(pwd)
TARGET_AIRFLOW_HOME="${CURRENT_DIR}/airflow"
BASHRC="$HOME/.bashrc"

# Check if the function already exists to avoid duplicate entries
if ! grep -q "function setup_airflow_env" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# --- Airflow & Python Environment Setup (Auto-generated) ---" >> "$BASHRC"
    echo "function setup_airflow_env() {" >> "$BASHRC"
    echo "    # 1. Export Critical Airflow Variables" >> "$BASHRC"
    echo "    export AIRFLOW_HOME=\"$TARGET_AIRFLOW_HOME\"" >> "$BASHRC"
    echo "    export PYTHONPATH=\"$TARGET_AIRFLOW_HOME:\$PYTHONPATH\"" >> "$BASHRC"
    echo "    export AIRFLOW__CORE__LOAD_EXAMPLES=False" >> "$BASHRC"
    echo "" >> "$BASHRC"
    echo "    # 2. Activate Venv (if it exists)" >> "$BASHRC"
    echo "    if [ -f \".venv/bin/activate\" ]; then" >> "$BASHRC"
    echo "        source .venv/bin/activate" >> "$BASHRC"
    echo "    fi" >> "$BASHRC"
    echo "}" >> "$BASHRC"
    echo "" >> "$BASHRC"
    echo "# Automatically run this setup when the shell starts" >> "$BASHRC"
    echo "setup_airflow_env" >> "$BASHRC"
    
    echo "✅ Configured .bashrc with auto-loading 'setup_airflow_env()' function"
else
    echo "ℹ️  .bashrc is already configured."
fi

# ------------------------------------------------------------------
# 4. Apply Environment Immediately (For this script's session)
# ------------------------------------------------------------------
export AIRFLOW_HOME="$TARGET_AIRFLOW_HOME"
export PYTHONPATH="$TARGET_AIRFLOW_HOME:$PYTHONPATH"
export AIRFLOW__CORE__LOAD_EXAMPLES=False

# ------------------------------------------------------------------
# 5. Reset DB & Create Admin (Cleanup)
# ------------------------------------------------------------------
echo "🧹 Resetting Airflow DB..."
uv run airflow db reset -y > /dev/null 2>&1

# Create the password file if it doesn't exist
mkdir -p "$TARGET_AIRFLOW_HOME"
PASS_FILE="$TARGET_AIRFLOW_HOME/simple_auth_manager_passwords.json.generated"

if [ ! -f "$PASS_FILE" ]; then
    echo '{"admin": "admin"}' > "$PASS_FILE"
    echo "✅ Created default admin credentials (user: admin / pass: admin)"
fi

echo "✅ Python Setup Complete."

# ------------------------------------------------------------------
# 6. Final User Instructions
# ------------------------------------------------------------------
echo ""
echo "=================================================================="
echo "🎉 SETUP SUCCESSFUL!"
echo "=================================================================="
echo "Your environment is now configured automatically."
echo ""
echo "👉 OPTION A: OPEN A NEW TERMINAL"
echo "   The environment will activate automatically."
echo ""
echo "👉 OPTION B: USE CURRENT TERMINAL"
echo "   Run this command to reload settings:"
echo "   source ~/.bashrc"
echo ""
echo "🚀 TO START AIRFLOW:"
echo "   airflow standalone"
echo ""
echo "ℹ️  Variables set:"
echo "   AIRFLOW_HOME = $TARGET_AIRFLOW_HOME"
echo "   PYTHONPATH   = Includes project root"
echo "=================================================================="
echo ""
