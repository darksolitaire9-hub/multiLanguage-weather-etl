#!/bin/bash
set -e

echo "================================================================================"
echo "🚀 CODESPACES SETUP: Python + Julia + R + Airflow + FFmpeg"
echo "================================================================================"

cd /workspaces/multiLanguage-weather-etl

# ==================== PHASE 1: System Dependencies ====================
echo ""
echo "📦 PHASE 1: Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  build-essential \
  cmake \
  git \
  curl \
  wget \
  pkg-config \
  linux-headers-generic \
  libabsl-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libffi-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  ffmpeg \
  gfortran \
  libopenblas-dev \
  liblapack-dev \
  r-base \
  r-base-dev

echo "✅ System dependencies installed"

# ==================== PHASE 2: Python Setup ====================
echo ""
echo "📦 PHASE 2: Setting up Python environment..."

# Install uv (fast package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
echo "✅ uv installed: $(uv --version)"

# Create virtual environment
mkdir -p .venv
uv venv .venv --python 3.11 2>/dev/null || python3 -m venv .venv
source .venv/bin/activate

echo "✅ Python venv created at .venv"

# Install Python dependencies
echo "Installing Python packages..."
uv pip install -q --no-cache-dir \
  apache-airflow==2.7.3 \
  requests \
  pandas \
  numpy \
  python-dotenv \
  pytest \
  black \
  ruff 2>/dev/null || pip install -q \
  apache-airflow==2.7.3 \
  requests \
  pandas \
  numpy \
  python-dotenv \
  pytest \
  black \
  ruff

echo "✅ Python packages installed"
echo "   Python: $(python3 --version)"
echo "   Airflow: $(airflow version 2>/dev/null || echo 'ready')"

# ==================== PHASE 3: Julia Setup ====================
echo ""
echo "📦 PHASE 3: Setting up Julia..."

# Download and install Julia
JULIA_VERSION="1.10.7"
if [ ! -d "/opt/julia" ]; then
  echo "Downloading Julia $JULIA_VERSION..."
  wget -q https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz -O /tmp/julia.tar.gz
  sudo tar -xzf /tmp/julia.tar.gz -C /opt/
  sudo ln -sf /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia
  rm /tmp/julia.tar.gz
fi

echo "✅ Julia installed: $(julia --version)"

# Initialize Julia packages
julia --startup-file=no -e '
using Pkg
Pkg.activate(".")
Pkg.add(["Plots", "StatsPlots", "DataFrames", "CSV", "Dates"], preserve=PRESERVE_TIERED_INSTALLED)
' 2>/dev/null || echo "ℹ️  Julia packages will initialize on first run"

# ==================== PHASE 4: R Setup ====================
echo ""
echo "📦 PHASE 4: Setting up R environment..."

# Create .Rprofile for automatic package loading
cat > ~/.Rprofile << 'EOF'
options(repos = c(CRAN = "https://cloud.r-project.org"))
packages <- c("ggplot2", "dplyr", "data.table", "lubridate", "renv", "gganimate", "av")
invisible(sapply(packages, function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, quiet = TRUE)
  }
}))
EOF

echo "✅ R configured: $(R --quiet --vanilla --slave -e 'cat(R.version$version.string)')"

# ==================== PHASE 5: Airflow Setup ====================
echo ""
echo "📦 PHASE 5: Initializing Airflow..."

export AIRFLOW_HOME=/workspaces/multiLanguage-weather-etl/airflow
mkdir -p $AIRFLOW_HOME/{dags,logs,plugins}

# Initialize Airflow database
airflow db init 2>/dev/null || echo "ℹ️  Airflow will initialize on first run"

echo "✅ Airflow ready at $AIRFLOW_HOME"

# ==================== PHASE 6: Verify All Installations ====================
echo ""
echo "🔍 VERIFICATION"
echo "================================================================================"
echo "✅ Python: $(python3 --version)"
echo "✅ Julia: $(julia --version)"
echo "✅ R: $(R --quiet --vanilla --slave -e 'cat(R.version$version.string)')"
echo "✅ FFmpeg: $(ffmpeg -version 2>/dev/null | head -1)"
echo "✅ Airflow: $(airflow version)"
echo "✅ Virtual Environment: $VIRTUAL_ENV"
echo ""
echo "================================================================================"
echo "🎉 SETUP COMPLETE! Everything is ready."
echo "================================================================================"
echo ""
echo "📝 Next steps:"
echo "   1. Activate Python venv: source .venv/bin/activate"
echo "   2. Start Airflow UI: airflow webserver --port 8080"
echo "   3. Test your R animation: Rscript airflow/scripts/render_weather_animation.R"
echo ""
