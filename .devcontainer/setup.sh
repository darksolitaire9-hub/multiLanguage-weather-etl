#!/bin/bash
set -e

echo "🚀 Setting up Multi-Language Weather ETL environment..."

# Update system
sudo apt-get update

# Install uv (modern Python package manager)
echo "📦 Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Install Python dependencies with uv
echo "📦 Installing Python packages with uv..."
uv pip install --system apache-airflow==3.0.6 \
    requests==2.32.3 \
    pandas==2.2.3 \
    python-dotenv==1.0.1

# Install R packages
echo "📊 Installing R packages..."
sudo R -e "install.packages(c('DBI', 'RSQLite', 'ggplot2', 'dplyr', 'readr', 'lubridate'), repos='https://cloud.r-project.org/')"

# Install Julia packages
echo "💎 Installing Julia packages..."
julia -e 'using Pkg; Pkg.add(["DataFrames", "SQLite", "Statistics", "Dates", "CSV"])'

# Create project structure
echo "📁 Creating project directories..."
mkdir -p python
mkdir -p r
mkdir -p julia
mkdir -p airflow/dags
mkdir -p data
mkdir -p outputs/plots
mkdir -p outputs/reports
mkdir -p logs

# Initialize Airflow with updated configuration
echo "🌬️ Initializing Airflow 3.0..."
export AIRFLOW_HOME=$(pwd)/airflow

# Create airflow.cfg with SQLite backend
cat > airflow/airflow.cfg <<EOL
[core]
dags_folder = $(pwd)/airflow/dags
base_log_folder = $(pwd)/logs
executor = LocalExecutor
load_examples = False

[database]
sql_alchemy_conn = sqlite:///$(pwd)/airflow/airflow.db

[webserver]
base_url = http://localhost:8080
web_server_port = 8080

[scheduler]
scheduler_heartbeat_sec = 5
EOL

# Initialize database
airflow db migrate

# Create Airflow user (username: admin, password: admin)
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin

echo "✅ Setup complete!"
echo ""
echo "📝 Installed Versions:"
python --version
uv --version
R --version | head -n 1
julia --version
echo "Airflow $(airflow version)"
echo ""
echo "🚀 Next steps:"
echo "1. Start Airflow: export AIRFLOW_HOME=\$(pwd)/airflow && airflow standalone"
echo "2. Access UI at http://localhost:8080 (admin/admin)"
echo "3. Begin building your pipeline scripts!"
