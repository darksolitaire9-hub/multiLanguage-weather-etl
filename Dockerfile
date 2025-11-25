FROM ubuntu:22.04

# Prevent prompts
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    AIRFLOW_HOME=/workspaces/multiLanguage-weather-etl/airflow

# Install minimal base packages first (fail-fast optimization)
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install uv FIRST and verify it works (fail-fast if uv installation fails)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    uv --version

# Install Julia 1.10.3 (fast, independent installation)
RUN JULIA_VER="1.10.3" && \
    JULIA_TAR="julia-${JULIA_VER}-linux-x86_64.tar.gz" && \
    JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.10/${JULIA_TAR}" && \
    wget -q "$JULIA_URL" -O /tmp/"${JULIA_TAR}" && \
    tar -xzf /tmp/"${JULIA_TAR}" -C /opt && \
    ln -sf /opt/julia-${JULIA_VER}/bin/julia /usr/local/bin/julia && \
    rm /tmp/"${JULIA_TAR}"

# Now install heavy system dependencies (Python, R, ffmpeg, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    software-properties-common \
    python3 \
    python3-venv \
    r-base \
    r-base-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    ffmpeg \
    bzip2 \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspaces/multiLanguage-weather-etl

# Copy dependency files
COPY pyproject.toml uv.lock* ./
COPY Project.toml Manifest.toml* ./
COPY renv.lock renv/ dependency.R ./

# Install Python deps using uv sync
RUN uv sync --frozen

# Install Airflow separately (if not in pyproject.toml)
RUN uv pip install "apache-airflow[celery,postgres,sqlite]==2.9.1"

# Install R deps
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')" && \
    R -e "renv::restore()"

# Install Julia deps
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Install Jupyter kernels
RUN uv pip install ipykernel && \
    uv run python -m ipykernel install --user --name python3

RUN R -e "install.packages('IRkernel', repos='https://cloud.r-project.org'); IRkernel::installspec(user = FALSE)"

# Cleanup
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

CMD ["/bin/bash"]
