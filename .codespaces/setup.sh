#!/bin/bash
set -e

echo "📦 Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  wget \
  git \
  ca-certificates \
  r-base \
  r-base-dev \
  ffmpeg \
  libavfilter-dev \
  gdal-bin \
  libgdal-dev \
  libgeos-dev \
  libproj-dev \
  gh

    gh

echo ""
echo "🧮 Installing Julia..."
wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.7-linux-x86_64.tar.gz
tar -xzf julia-1.10.7-linux-x86_64.tar.gz
sudo mv julia-1.10.7 /opt/julia
sudo ln -s /opt/julia/bin/julia /usr/local/bin/julia
rm julia-1.10.7-linux-x86_64.tar.gz
julia --version



echo ""
echo "🐍 Setting up Python with uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Create and activate virtual environment
uv venv .venv
source .venv/bin/activate

# Install dependencies from pyproject.toml
echo "📚 Installing Python dependencies..."
uv pip install "apache-airflow[celery,sqlite]==2.9.1"
uv pip install pytest pytest-cov ruff

echo ""
echo "📊 Setting up R packages..."
Rscript -e 'if (!require("renv")) install.packages("renv"); renv::restore()'

echo ""
echo "🧮 Setting up Julia..."
julia --project=. -e 'using Pkg; Pkg.instantiate()'

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Activate venv: source .venv/bin/activate"
echo "   2. Start Airflow: airflow standalone"
echo "   3. Visit: http://localhost:8080"
