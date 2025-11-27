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
  r-dev \
  ffmpeg \
  gh

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
