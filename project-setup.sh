#!/bin/bash
set -eu  # Exit on error, treat unset variables as error

# ===== PROJECT AUTO-SETUP SCRIPT: FOR CODESPACE OR LOCAL DEV =====
# This script creates a non-root user, sets Airflow and all paths to be local to your repo

PROJECT_HOME="/workspaces/multiLanguage-weather-etl"
AIRFLOW_HOME="$PROJECT_HOME/airflow"
DAGS_HOME="$PROJECT_HOME/dags"
USER_NAME="etluser"
USER_HOME="/home/$USER_NAME"

# 1. Create user only if missing.
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    echo "$USER_NAME:multiETL2025!" | chpasswd   # set a default password
fi

# 2. Set project folder ownership
chown -R "$USER_NAME:$USER_NAME" "$PROJECT_HOME"

# 3. Prepare Airflow and DAG directories
mkdir -p "$AIRFLOW_HOME"
mkdir -p "$DAGS_HOME"
chown -R "$USER_NAME:$USER_NAME" "$AIRFLOW_HOME" "$DAGS_HOME"

# 4. As the user: configure environment and initialize Airflow
su - "$USER_NAME" << EOF
echo 'export AIRFLOW_HOME=$AIRFLOW_HOME' >> ~/.bashrc
export AIRFLOW_HOME=$AIRFLOW_HOME

# Optional: set dags_folder in airflow.cfg if needed:
if [ -f "\$AIRFLOW_HOME/airflow.cfg" ]; then
    grep -q "^dags_folder" "\$AIRFLOW_HOME/airflow.cfg" || \
        echo "dags_folder = $DAGS_HOME" >> "\$AIRFLOW_HOME/airflow.cfg"
fi

airflow db init || true  # Safe to re-run
mkdir -p "\$AIRFLOW_HOME/dags"
ln -snf "$DAGS_HOME" "\$AIRFLOW_HOME/dags"

airflow users create \
  --username admin \
  --firstname admin \
  --lastname user \
  --role Admin \
  --email admin@example.com \
  --password admin

echo "whoami: \$(whoami)"
echo "AIRFLOW_HOME: \$AIRFLOW_HOME"
echo "DAGS_HOME: \$AIRFLOW_HOME/dags"
EOF

echo "✅ Setup complete. Now open a new bash tab, run su - $USER_NAME, and you're ready!"

# Optionally, log results to README.md or setup.log for future reproducibility.
