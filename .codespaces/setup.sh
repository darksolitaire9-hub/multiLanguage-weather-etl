#!/bin/bash

################################################################################
# Multi-Language Weather ETL - Dev Environment Setup Script
# 
# Purpose: Robustly configure a complete development environment for the
#          multiLanguage-weather-etl project with Python, R, and Julia support.
#
# Features:
#   - Step-by-step installation with comprehensive error checking
#   - Clear diagnostic messages on failure
#   - Version verification after each major installation
#   - Graceful error handling and early exit on failures
#   - Colorized output for better readability
#
# Usage:
#   bash .codespaces/setup.sh
#
# Prerequisites:
#   - Running in Ubuntu 22.04 (or compatible Debian-based system)
#   - User must have sudo privileges
#   - Internet connectivity required for package downloads
#
################################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

################################################################################
# COLOR DEFINITIONS FOR OUTPUT
################################################################################

RED='\033[0;31m'      # Error messages
GREEN='\033[0;32m'    # Success messages
YELLOW='\033[1;33m'   # Warnings
BLUE='\033[0;34m'     # Section headers
NC='\033[0m'          # No Color (reset)

################################################################################
# UTILITY FUNCTIONS
################################################################################

# Print a section header with visual emphasis
print_header() {
    echo ""
    echo -e "${BLUE}================================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================================${NC}"
    echo ""
}

# Print a success message
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Print an error message
print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

# Print a warning message
print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

# Print an informational message
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if a command exists and is executable
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Execute a command with error handling
execute_command() {
    local cmd="$1"
    local description="$2"
    
    if eval "$cmd"; then
        print_success "$description completed"
        return 0
    else
        print_error "$description failed with exit code $?"
        return 1
    fi
}

# Verify that a command is available after installation
verify_command() {
    local cmd="$1"
    local description="$2"
    
    if command_exists "$cmd"; then
        local version_info=$($cmd --version 2>/dev/null | head -1 || echo "version not available")
        print_success "$description: $version_info"
        return 0
    else
        print_error "$description is not available in PATH"
        return 1
    fi
}

# Check if a directory exists and is writable
verify_directory() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ] && [ -w "$dir" ]; then
        print_success "$description exists and is writable"
        return 0
    else
        print_error "$description does not exist or is not writable: $dir"
        return 1
    fi
}

################################################################################
# ENVIRONMENT SETUP
################################################################################

print_header "Initializing Development Environment Setup"

# Capture start time for total duration
START_TIME=$(date +%s)

# Define workspace paths
WORKSPACE_DIR="${1:-.}"
VENV_DIR="${WORKSPACE_DIR}/.venv"
JULIA_PROJECT_DIR="${WORKSPACE_DIR}"

print_info "Workspace directory: $WORKSPACE_DIR"
print_info "Virtual environment: $VENV_DIR"
print_info "Julia project: $JULIA_PROJECT_DIR"

# Verify we can write to the workspace
verify_directory "$WORKSPACE_DIR" "Workspace directory" || exit 1

################################################################################
# PHASE 1: SYSTEM DEPENDENCIES
################################################################################

print_header "PHASE 1: System Dependencies Installation"

print_info "Updating package manager..."
if ! sudo apt-get update -qq 2>/dev/null; then
    print_error "Failed to update package manager (apt-get update)"
    exit 1
fi
print_success "Package manager updated"

print_info "Installing required system packages..."
print_info "This may take 2-3 minutes on first run..."

SYSTEM_PACKAGES=(
    # Build tools
    "build-essential"      # Compiler toolchain
    "curl"                 # HTTP client
    "wget"                 # File download utility
    "git"                  # Version control
    "ca-certificates"      # SSL/TLS certificates
    
    # R language runtime and development
    "r-base"               # R language interpreter
    "r-base-dev"           # R development headers and libraries
    
    # Multimedia and image processing
    "ffmpeg"               # Video/audio processing
    "libavfilter-dev"      # FFmpeg filter library (dev headers)
    
    # Geospatial libraries (for GDAL/PROJ support)
    "gdal-bin"             # GDAL command-line utilities
    "libgdal-dev"          # GDAL development headers
    "libgeos-dev"          # GEOS (geometry) development headers
    "libproj-dev"          # PROJ (projection) development headers
    
    # GitHub CLI for repository operations
    "gh"                   # GitHub command-line tool
    
    # Build system for R packages (CRITICAL for renv)
    "cmake"                # CMake build system (required by R package 's2')
    "libudunits2-dev"      # Units library (required by R package 'units')
    "libabsl-dev"          # Google Abseil C++ library (used by 's2', avoids vendored build)
)

if ! sudo apt-get install -y --no-install-recommends "${SYSTEM_PACKAGES[@]}" 2>/dev/null; then
    print_error "Failed to install one or more system packages"
    print_info "Attempting to diagnose which packages failed..."
    
    # Try to identify problematic packages by installing individually
    for pkg in "${SYSTEM_PACKAGES[@]}"; do
        if ! sudo apt-get install -y --no-install-recommends "$pkg" 2>/dev/null; then
            print_warning "Failed to install: $pkg (this may be non-critical)"
        fi
    done
fi

print_success "System packages installation completed"

# Verify critical tools are available
print_info "Verifying critical system tools..."

verify_command "cmake" "CMake" || {
    print_error "cmake is required for building R packages (especially 's2')"
    exit 1
}

verify_command "R" "R language interpreter" || {
    print_error "R language interpreter not found"
    exit 1
}

verify_command "git" "Git version control" || {
    print_warning "Git not available (may affect some operations)"
}

# Display system dependency versions
print_info "System dependency versions:"
echo "  cmake:         $(cmake --version | head -1)"
echo "  R:             $(R --version | head -1)"
[ -f /usr/include/units.h ] && echo "  udunits2:      installed" || echo "  udunits2:      not found (may cause issues)"
[ -f /usr/include/absl ] && echo "  abseil:        installed" || echo "  abseil:        not found (R packages may rebuild)"

print_success "PHASE 1 COMPLETE: System dependencies ready"

################################################################################
# PHASE 2: JULIA INSTALLATION
################################################################################

print_header "PHASE 2: Julia Language Installation"

JULIA_VERSION="1.10.7"
JULIA_INSTALL_DIR="/opt/julia"
JULIA_ARCHIVE="julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.10/${JULIA_ARCHIVE}"

# Check if Julia is already installed
if command_exists "julia"; then
    INSTALLED_VERSION=$(julia --version 2>/dev/null | awk '{print $3}' || echo "unknown")
    print_info "Julia already installed: version $INSTALLED_VERSION"
    
    # Optionally verify it's the right version
    if [ "$INSTALLED_VERSION" == "$JULIA_VERSION" ]; then
        print_success "Julia version matches target ($JULIA_VERSION)"
    else
        print_warning "Julia version differs from target ($INSTALLED_VERSION vs $JULIA_VERSION)"
        print_info "Proceeding with current installation..."
    fi
else
    print_info "Julia not found, installing version $JULIA_VERSION..."
    print_info "Download URL: $JULIA_URL"
    
    # Create temporary directory for download
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT  # Cleanup on exit
    
    print_info "Downloading Julia (this may take 1-2 minutes)..."
    if ! wget -q "$JULIA_URL" -O "$TEMP_DIR/$JULIA_ARCHIVE" 2>/dev/null; then
        print_error "Failed to download Julia from $JULIA_URL"
        print_info "Check internet connection and URL availability"
        exit 1
    fi
    print_success "Julia downloaded successfully"
    
    print_info "Extracting Julia archive..."
    if ! tar -xzf "$TEMP_DIR/$JULIA_ARCHIVE" -C "$TEMP_DIR" 2>/dev/null; then
        print_error "Failed to extract Julia archive"
        exit 1
    fi
    print_success "Julia extracted"
    
    print_info "Installing Julia to $JULIA_INSTALL_DIR..."
    if ! sudo mv "$TEMP_DIR/julia-${JULIA_VERSION}" "$JULIA_INSTALL_DIR" 2>/dev/null; then
        print_error "Failed to move Julia to $JULIA_INSTALL_DIR"
        exit 1
    fi
    print_success "Julia installed to $JULIA_INSTALL_DIR"
    
    print_info "Creating symbolic link..."
    if ! sudo ln -sf "$JULIA_INSTALL_DIR/bin/julia" /usr/local/bin/julia 2>/dev/null; then
        print_error "Failed to create symlink for julia"
        exit 1
    fi
    print_success "Julia symlink created in /usr/local/bin"
fi

# Verify Julia installation
verify_command "julia" "Julia language interpreter" || {
    print_error "Julia verification failed"
    exit 1
}

print_success "PHASE 2 COMPLETE: Julia ready"

################################################################################
# PHASE 3: PYTHON ENVIRONMENT WITH UV PACKAGE MANAGER
################################################################################

print_header "PHASE 3: Python Environment Setup (using uv)"

print_info "Installing uv package manager..."
print_info "uv is a modern, fast Python package manager (Rust-based)"

# Check if uv is already installed
if command_exists "uv"; then
    print_info "uv already installed: $(uv --version)"
else
    print_info "Downloading and installing uv..."
    if ! curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null; then
        print_error "Failed to install uv"
        exit 1
    fi
    print_success "uv installed successfully"
    
    # Add uv to PATH for current session
    export PATH="$HOME/.cargo/bin:$PATH"
fi

verify_command "uv" "uv package manager" || {
    print_error "uv is not available in PATH after installation"
    exit 1
}

# Create Python virtual environment
print_info "Creating Python virtual environment at $VENV_DIR..."
if [ -d "$VENV_DIR" ]; then
    print_warning "Virtual environment already exists at $VENV_DIR"
    print_info "Reusing existing environment (skip recreation)"
else
    if ! uv venv "$VENV_DIR" 2>/dev/null; then
        print_error "Failed to create virtual environment"
        exit 1
    fi
    print_success "Virtual environment created"
fi

# Activate virtual environment
print_info "Activating virtual environment..."
if [ ! -f "$VENV_DIR/bin/activate" ]; then
    print_error "Activation script not found at $VENV_DIR/bin/activate"
    exit 1
fi

# Source the activation script
source "$VENV_DIR/bin/activate"

# Verify activation
if [ -z "${VIRTUAL_ENV:-}" ] || [ "$VIRTUAL_ENV" != "$VENV_DIR" ]; then
    print_error "Virtual environment activation failed"
    print_info "VIRTUAL_ENV=$VIRTUAL_ENV, expected $VENV_DIR"
    exit 1
fi
print_success "Virtual environment activated: $VIRTUAL_ENV"

# Install Python packages
print_info "Installing Python packages from requirements..."
print_info "  - Apache Airflow 2.9.1 (with Celery and SQLite support)"
print_info "  - pytest (testing framework)"
print_info "  - pytest-cov (code coverage)"
print_info "  - ruff (Python linter/formatter)"
print_info "This may take 3-5 minutes..."

# Install core packages
if ! uv pip install "apache-airflow[celery,sqlite]==2.9.1" 2>/dev/null; then
    print_error "Failed to install Apache Airflow"
    exit 1
fi
print_success "Apache Airflow installed"

if ! uv pip install pytest pytest-cov ruff 2>/dev/null; then
    print_error "Failed to install testing and linting tools"
    exit 1
fi
print_success "Testing and linting tools installed"

# Verify critical Python packages
print_info "Verifying Python package installations..."

verify_command "airflow" "Apache Airflow CLI" || {
    print_error "Airflow command not found in PATH"
    exit 1
}

print_info "Python environment ready. Active environment: $VIRTUAL_ENV"
python3 --version

print_success "PHASE 3 COMPLETE: Python environment ready"

################################################################################
# PHASE 4: R PACKAGE MANAGEMENT WITH RENV
################################################################################

print_header "PHASE 4: R Package Management (renv)"

print_info "Verifying R is available..."
verify_command "Rscript" "R scripting engine" || {
    print_error "Rscript not found"
    exit 1
}

print_info "Setting up R package environment using renv..."
print_info "renv isolates project dependencies and improves reproducibility"
print_info "This may take 5-10 minutes on first run (packages will be built from source if needed)"
print_info "Critical packages being installed:"
print_info "  - s2: spherical geometry (requires cmake)"
print_info "  - units: units of measurement (requires libudunits2)"
print_info "  - Other ETL and data processing packages"

# Run renv restore with comprehensive error handling
if ! Rscript -e 'if (!require("renv")) install.packages("renv"); renv::restore()' 2>&1; then
    print_error "R package setup (renv::restore) failed"
    print_info "Troubleshooting tips:"
    print_info "  1. Check that system dependencies were installed: cmake, libudunits2-dev"
    print_info "  2. Review the error output above for specific package failures"
    print_info "  3. Try running: Rscript -e 'renv::status()' to see what's missing"
    print_info "  4. Some packages may need compilation; this is normal and takes time"
    exit 1
fi
print_success "R packages installed and restored via renv"

# Optional: Show R environment status
print_info "R package environment status:"
Rscript -e 'renv::status()' 2>/dev/null || print_warning "Could not retrieve renv status"

print_success "PHASE 4 COMPLETE: R packages ready"

################################################################################
# PHASE 5: JULIA PACKAGE MANAGEMENT
################################################################################

print_header "PHASE 5: Julia Package Management"

print_info "Initializing Julia project environment..."
print_info "Julia will use project directory: $JULIA_PROJECT_DIR"
print_info "This ensures reproducible package versions via Project.toml"

# Check if Project.toml exists
if [ ! -f "$JULIA_PROJECT_DIR/Project.toml" ]; then
    print_warning "Project.toml not found at $JULIA_PROJECT_DIR"
    print_info "Julia will use global environment (not recommended for reproducibility)"
    print_info "To fix this, run: julia --project=. -e 'using Pkg; Pkg.generate()' in your project"
fi

print_info "Installing Julia packages (this may take 3-5 minutes)..."
if ! julia --project="$JULIA_PROJECT_DIR" -e 'using Pkg; Pkg.instantiate()' 2>&1; then
    print_error "Julia package setup failed"
    print_info "Troubleshooting tips:"
    print_info "  1. Ensure Project.toml exists in: $JULIA_PROJECT_DIR"
    print_info "  2. Check that all required packages are listed in Project.toml"
    print_info "  3. Try running: julia --project=. -e 'using Pkg; Pkg.status()' to see what's installed"
    exit 1
fi
print_success "Julia packages instantiated"

# Optional: Show Julia environment status
print_info "Julia package environment status:"
julia --project="$JULIA_PROJECT_DIR" -e 'using Pkg; Pkg.status()' 2>/dev/null || print_warning "Could not retrieve Julia package status"

print_success "PHASE 5 COMPLETE: Julia packages ready"

################################################################################
# FINAL VERIFICATION AND SUMMARY
################################################################################

print_header "FINAL VERIFICATION"

print_info "Checking all critical tools and environments..."
echo ""

# Create a summary table of installations
print_info "Installation Summary:"
echo "────────────────────────────────────────────────────────────────"
echo "Component                 Status           Version/Info"
echo "────────────────────────────────────────────────────────────────"

# System tools
if command_exists "cmake"; then
    echo "cmake                     ✅ OK            $(cmake --version | head -1 | awk '{print $3}')"
else
    echo "cmake                     ❌ MISSING"
fi

if command_exists "R"; then
    echo "R interpreter             ✅ OK            $(R --version | head -1 | awk '{print $1, $2, $3}')"
else
    echo "R interpreter             ❌ MISSING"
fi

if command_exists "Rscript"; then
    echo "Rscript                   ✅ OK            Available"
else
    echo "Rscript                   ❌ MISSING"
fi

# Julia
if command_exists "julia"; then
    echo "Julia                     ✅ OK            $(julia --version | awk '{print $3}')"
else
    echo "Julia                     ❌ MISSING"
fi

# Python environment
if [ -n "${VIRTUAL_ENV:-}" ]; then
    echo "Python venv               ✅ OK            $(basename $VIRTUAL_ENV)"
else
    echo "Python venv               ❌ NOT ACTIVE"
fi

if command_exists "python"; then
    echo "Python                    ✅ OK            $(python --version | awk '{print $2}')"
else
    echo "Python                    ❌ MISSING"
fi

if command_exists "airflow"; then
    AIRFLOW_VER=$(airflow version 2>/dev/null | head -1 || echo "unknown")
    echo "Apache Airflow            ✅ OK            $AIRFLOW_VER"
else
    echo "Apache Airflow            ❌ MISSING"
fi

if command_exists "uv"; then
    echo "uv package manager        ✅ OK            $(uv --version | awk '{print $2}')"
else
    echo "uv package manager        ❌ MISSING"
fi

echo "────────────────────────────────────────────────────────────────"
echo ""

################################################################################
# COMPLETION AND NEXT STEPS
################################################################################

print_header "Setup Complete!"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

print_success "All installation phases completed successfully in ${MINUTES}m${SECONDS}s"

echo ""
print_info "Your development environment is now configured with:"
echo "  ✓ Python 3 with Apache Airflow 2.9.1"
echo "  ✓ R language with project-isolated packages (renv)"
echo "  ✓ Julia 1.10.7 with package management"
echo "  ✓ Build tools and geospatial libraries"
echo ""

print_info "NEXT STEPS:"
echo "────────────────────────────────────────────────────────────────"
echo ""
echo "  1. ACTIVATE Python virtual environment (if not already active):"
echo "     source .venv/bin/activate"
echo ""
echo "  2. VERIFY environments are ready:"
echo "     which python && python --version"
echo "     which R && R --version"
echo "     which julia && julia --version"
echo ""
echo "  3. START Apache Airflow:"
echo "     airflow standalone"
echo "     (Then visit: http://localhost:8080)"
echo ""
echo "  4. RUN your ETL pipeline:"
echo "     python src/main.py  (or your entry point)"
echo ""
echo "  5. RUN tests:"
echo "     pytest tests/ -v"
echo ""
echo "────────────────────────────────────────────────────────────────"
echo ""

print_info "For troubleshooting or rerunning individual phases:"
echo "  - Re-activate venv:  source .venv/bin/activate"
echo "  - Reinstall R pkgs:  Rscript -e 'renv::restore()'"
echo "  - Reinstall Julia:   julia --project=. -e 'using Pkg; Pkg.instantiate()'"
echo ""

print_success "Setup script finished. Happy coding! 🚀"
echo ""
