#!/bin/bash
set -e

echo "🚀 Setting up Multi-Language Weather ETL environment..."

# Update system
sudo apt-get update

# Install uv (Python package manager)
echo "📦 Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Install Python dependencies with uv
echo "📦 Installing Python packages with uv..."
uv pip install --system apache-airflow==3.0.6 \
    requests==2.32.3 \
    pandas==2.2.3 \
    python-dotenv==1.0.1

# ----------------- INSTALL R MANUALLY -----------------
echo "📊 Installing R (base) manually..."
sudo apt-get install -y --no-install-recommends software-properties-common dirmngr gpg wget
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 'E298A3A825C0D65DFD57CBB651716619E084DAB9'
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/'
sudo apt-get update
sudo apt-get install -y --no-install-recommends r-base

# Install R packages
echo "📊 Installing R packages..."
sudo Rscript -e "install.packages(c('DBI','RSQLite','ggplot2','dplyr','readr','lubridate'), repos='https://cloud.r-project.org/')"

# ----------------- INSTALL JULIA MANUALLY ----------------
echo "💎 Installing Julia manually..."
cd /tmp
wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.0-linux-x86_64.tar.gz
tar -xzf julia-1.10.0-linux-x86_64.tar.gz
sudo mv julia-1.10.0 /usr/local/julia
sudo ln -sf /usr/local/julia/bin/julia /usr/local/bin/julia
rm julia-1.10.0-linux-x86_64.tar.gz
cd -
julia --version
julia -e 'using Pkg; Pkg.add(["DataFrames", "SQLite", "Statistics", "Dates", "CSV"])'

# ------------------- CREATE PROJECT STRUCTURE ---------------
echo "📁 Creating project directories..."
mkdir -p python
mkdir -p r
mkdir -p julia
mkdir -p airflow/dags
mkdir -p data
mkdir -p outputs/plots
mkdir -p outputs/reports
mkdir -p logs

# ----------------- AIRFLOW CONFIGURATION --------------------
echo "🌬️ Initializing Airflow 3.0..."
export AIRFLOW_HOME=$(pwd)/airflow

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

airflow db migrate

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
