#!/bin/bash
set -euxo pipefail

# ---- Core system dependencies ----
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y
apt-get install -y git curl wget ca-certificates build-essential software-properties-common \
    locales libssl-dev libcurl4-openssl-dev libxml2-dev \
    libsqlite3-dev sqlite3 bzip2 unzip ffmpeg

# ---- GitHub CLI ----
type -p curl >/dev/null || apt-get install -y curl
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
  tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt-get update && apt-get install -y gh

# ---- Python (latest, with venv and uv) ----
apt-get install -y python3 python3-venv python3-pip
update-alternatives --install /usr/bin/python python /usr/bin/python3 1

pip3 install --upgrade uv
apt-get remove -y python3-pip
apt-get autoremove -y

# ---- Project Python virtual environment + Airflow install ----
python3 -m venv .venv
source .venv/bin/activate
uv pip install --upgrade pip setuptools wheel
uv pip install "apache-airflow[celery,postgres,sqlite]==2.9.1"
# If you have other deps, uncomment next line:
# uv pip install -r requirements.txt

# --------- R base install ---------
apt-get install -y --no-install-recommends r-base r-base-dev

# --------- Julia install ---------
JULIA_VER="1.10.3"
JULIA_TAR="julia-${JULIA_VER}-linux-x86_64.tar.gz"
JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.10/${JULIA_TAR}"

echo "Downloading Julia from $JULIA_URL"
wget -O "/tmp/${JULIA_TAR}" "${JULIA_URL}"
tar -xzf "/tmp/${JULIA_TAR}" -C /tmp
rm -rf /opt/julia
mv "/tmp/julia-${JULIA_VER}" /opt/julia
ln -sf /opt/julia/bin/julia /usr/local/bin/julia
export PATH="/usr/local/bin:${PATH}"
rm "/tmp/${JULIA_TAR}"

echo "Testing Julia install..."
julia --version

# Clean up
apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

echo "✅ All dev tools, Python (.venv + uv), Airflow (local), R, and Julia installed.
echo "⚡ Activate with: source .venv/bin/activate"
