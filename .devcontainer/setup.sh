#!/bin/bash
set -euxo pipefail

# Update and install core developer tools
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y
apt-get install -y git curl wget ca-certificates build-essential software-properties-common \
    locales libssl-dev libcurl4-openssl-dev libxml2-dev \
    libsqlite3-dev sqlite3 bzip2 unzip

# ---- Add ffmpeg (media processing tools) ----
apt-get install -y ffmpeg

# ---- GitHub CLI (gh) install ----
type -p curl >/dev/null || apt-get install -y curl
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
  tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
  apt-get update && \
  apt-get install -y gh

# ---- Python (python3, venv, uv only—no pip after install) ----
apt-get install -y python3 python3-venv python3-pip
update-alternatives --install /usr/bin/python python /usr/bin/python3 1

pip3 install --upgrade uv
apt-get remove -y python3-pip
apt-get autoremove -y

# ---- Airflow (install via uv in persistent venv, available via /usr/local/bin/airflow) ----
python3 -m venv /opt/airflow-venv
source /opt/airflow-venv/bin/activate
uv pip install "apache-airflow[celery,postgres,sqlite]==2.9.1"
ln -sf /opt/airflow-venv/bin/airflow /usr/local/bin/airflow
deactivate

# Test Airflow installation
airflow version || echo "Airflow not found, check /opt/airflow-venv/bin"

# ---- R base install (with dev headers) ----
apt-get install -y --no-install-recommends r-base r-base-dev

# ---- Julia install (latest stable, robust path) ----
JULIA_VER="1.10.3"
JULIA_TAR="julia-${JULIA_VER}-linux-x86_64.tar.gz"
JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.10/${JULIA_TAR}"

echo "Downloading Julia from $JULIA_URL"
wget -O "/tmp/${JULIA_TAR}" "${JULIA_URL}"

echo "Extracting Julia..."
tar -xzf "/tmp/${JULIA_TAR}" -C /tmp

echo "Moving Julia to /opt/julia"
rm -rf /opt/julia
mv "/tmp/julia-${JULIA_VER}" /opt/julia

echo "Creating symlink for Julia in /usr/local/bin"
ln -sf /opt/julia/bin/julia /usr/local/bin/julia

export PATH="/usr/local/bin:${PATH}"

rm "/tmp/${JULIA_TAR}"

echo "Testing Julia install..."
julia --version

# ---- Jupyter kernels for Python, R, Julia ----
uv pip install ipykernel
python3 -m ipykernel install --user --name python3

R -e 'if (!require("IRkernel")) install.packages("IRkernel", repos="https://cloud.r-project.org"); IRkernel::installspec(user = FALSE)'

julia -e 'using Pkg; Pkg.add("IJulia"); using IJulia; IJulia.notebook()'

# Clean up
apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

echo "✅ All dev tools, Python (uv), Airflow in persistent venv, R, Julia, and Jupyter kernels installed."
