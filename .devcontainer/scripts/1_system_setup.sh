#!/bin/bash
set -e

echo "📦 [1/3] Installing System Dependencies..."

# 1. Update Repos
sudo apt-get update

# 2. Install All Dependencies
sudo apt-get install -y \
    libavfilter-dev \
    libavformat-dev \
    libavcodec-dev \
    libavutil-dev \
    ffmpeg \
    libmagick++-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    cmake \
    pandoc \
    libudunits2-0 \
    libgdal32

# 3. Cleanup
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/* 

echo "✅ System Dependencies Installed."
