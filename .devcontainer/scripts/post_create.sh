#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🚀 Starting Dev Container Setup..."

# Step 1: System setup
bash "$SCRIPT_DIR/1_system_setup.sh"

# Step 2: Python setup (Uncomment after Step 1 works)
bash "$SCRIPT_DIR/2_python_setup.sh"

# Step 3: R setup (Uncomment after Step 2 works)
bash "$SCRIPT_DIR/3_r_setup.sh"

echo "✅ Dev Container Setup Complete!"
