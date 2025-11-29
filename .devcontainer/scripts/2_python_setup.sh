#!/bin/bash
set -e

echo "🐍 [2/3] Setting up Python Environment..."

# 1. Install uv
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# 2. Sync Dependencies
if [ ! -f "pyproject.toml" ]; then
    echo "❌ Error: pyproject.toml not found"
    exit 1
fi
echo "Syncing Python dependencies..."
uv sync

# 3. Configure Environment Variables (PERMANENTLY in .bashrc)
CURRENT_DIR=$(pwd)
TARGET_AIRFLOW_HOME="${CURRENT_DIR}/airflow"

# Define the lines to add
lines=(
    "export AIRFLOW_HOME=\"$TARGET_AIRFLOW_HOME\""
    "export PYTHONPATH=\"$TARGET_AIRFLOW_HOME:\$PYTHONPATH\""
    "export AIRFLOW__CORE__LOAD_EXAMPLES=False"
    "alias run_airflow='source .venv/bin/activate && airflow standalone'"
)

# Append ONLY to .bashrc
target_file="$HOME/.bashrc"
touch "$target_file"
echo "" >> "$target_file"
echo "# --- Airflow Config (Auto-generated) ---" >> "$target_file"
for line in "${lines[@]}"; do
    if ! grep -Fxq "$line" "$target_file"; then
        echo "$line" >> "$target_file"
    fi
done

# Export for current session immediately
export AIRFLOW_HOME="$TARGET_AIRFLOW_HOME"
export PYTHONPATH="$TARGET_AIRFLOW_HOME:$PYTHONPATH"
export AIRFLOW__CORE__LOAD_EXAMPLES=False

# 4. Reset DB (Cleanup)
echo "🧹 Resetting Airflow DB..."
uv run airflow db reset -y > /dev/null 2>&1

# 5. Create Admin User (Ensure password file exists)
mkdir -p "$TARGET_AIRFLOW_HOME"
PASS_FILE="$TARGET_AIRFLOW_HOME/simple_auth_manager_passwords.json.generated"
if [ ! -f "$PASS_FILE" ]; then
    echo '{"admin": "admin"}' > "$PASS_FILE"
    echo "✅ Created default admin credentials (user: admin / pass: admin)"
fi

echo "✅ Python Setup Complete."
