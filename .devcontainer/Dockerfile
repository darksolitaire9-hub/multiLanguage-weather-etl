# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Enable caching for apt package manager
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Install system dependencies with BuildKit cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    git \
    gh \
    python3 \
    python3-dev \
    python3-venv \
    r-base \
    r-base-dev \
    julia \
    ffmpeg \
    vim \
    nano \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Python: Create venv and install packages with cache
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m venv /opt/python-venv && \
    /opt/python-venv/bin/pip install --upgrade pip && \
    /opt/python-venv/bin/pip install uv

# Install Airflow with uv (cache friendly)
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/python-venv/bin/uv pip install \
    "apache-airflow[celery,postgres,sqlite]==2.9.1" \
    requests \
    polars

ENV PATH="/opt/python-venv/bin:$PATH"
ENV AIRFLOW_HOME="/workspaces/multiLanguage-weather-etl/airflow"

# Julia: Precompile standard packages
# (Julia's own package manager handles caching in ~/.julia)
RUN julia --eval 'using Pkg; Pkg.add(["CSV", "DataFrames", "JSON", "HTTP"]); Pkg.precompile()' || true

# R: Create library directory and install base packages
ENV R_LIBS_USER="/opt/R-packages"
RUN mkdir -p ${R_LIBS_USER} && \
    R --quiet --slave --vanilla -e 'install.packages(c("tidyverse", "renv"), repos="http://cran.r-project.org", lib="/opt/R-packages")' || true

# Create non-root user for development
RUN useradd -m -s /bin/bash vscode && \
    mkdir -p /home/vscode/.julia && \
    mkdir -p /home/vscode/.cache/pip && \
    mkdir -p /home/vscode/.config && \
    chown -R vscode:vscode /home/vscode && \
    mkdir -p /workspaces && \
    chown vscode:vscode /workspaces

USER vscode
WORKDIR /workspaces/multiLanguage-weather-etl

# Verify installations
RUN python --version && \
    uv --version && \
    airflow version && \
    julia --version && \
    R --version && \
    git --version && \
    gh --version
