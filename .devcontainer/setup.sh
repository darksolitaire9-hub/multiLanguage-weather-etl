#!/bin/bash
set -euxo pipefail

# Update and install core developer tools
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y
apt-get install -y git curl wget ca-certificates build-essential software-properties-common \
    locales libssl-dev libcurl4-openssl-dev libxml2-dev \
    libsqlite3-dev sqlite3 bzip2 unzip

# Python (ensure python3+pip, uv, venv)
apt-get install -y python3 python3-pip python3-venv
pip3 install --upgrade pip uv

# R base install (with dev headers)
apt-get install -y --no-install-recommends r-base r-base-dev

# Julia latest stable
JULIA_VER="1.10.3"
wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-${JULIA_VER}-linux-x86_64.tar.gz
tar -xzf julia-${JULIA_VER}-linux-x86_64.tar.gz
mv julia-${JULIA_VER} /opt/julia
ln -sf /opt/julia/bin/julia /usr/local/bin/julia
rm julia-${JULIA_VER}-linux-x86_64.tar.gz

# Airflow with Celery, Postgres, SQLite support
pip3 install "apache-airflow[celery,postgres,sqlite]==2.9.1"

# Register Jupyter kernels for Python, R, Julia
python3 -m pip install ipykernel
python3 -m ipykernel install --user --name python3

R -e 'if (!require("IRkernel")) install.packages("IRkernel", repos="https://cloud.r-project.org"); IRkernel::installspec(user = FALSE)'

julia -e 'using Pkg; Pkg.add("IJulia"); using IJulia; IJulia.notebook()'

# Clean up apt cache
apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

echo "✅ All dev tools, languages, and Jupyter kernels installed."
