#!/bin/bash
set -e

echo "📦 [1/3] Installing System Dependencies..."

sudo apt-get update

# Install FFmpeg libraries for R's av package (video rendering)
sudo apt-get install -y \
    libavfilter-dev \
    libavformat-dev \
    libavcodec-dev \
    libavutil-dev \
    ffmpeg

sudo apt-get clean
rm -rf /var/lib/apt/lists/*

echo "✅ System Dependencies Installed (FFmpeg for video rendering)."
