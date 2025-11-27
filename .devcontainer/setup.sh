#!/bin/bash
set -e

echo "🚀 Setting up Multi-Language Weather ETL environment..."

# Activate Python venv
source /opt/python-venv/bin/activate
export AIRFLOW_HOME=$(pwd)/airflow

# ============================================
# Initialize Airflow (project-local)
# ============================================
echo "📦 Initializing Airflow..."
mkdir -p $AIRFLOW_HOME/dags
mkdir -p $AIRFLOW_HOME/logs
mkdir -p $AIRFLOW_HOME/plugins

# Only init if not already initialized
if [ ! -f "$AIRFLOW_HOME/airflow.db" ]; then
    airflow db init
    echo "✅ Airflow initialized at: $AIRFLOW_HOME"
else
    echo "✅ Airflow already initialized (found airflow.db)"
fi

# ============================================
# Julia: Instantiate project environment
# ============================================
echo "📦 Setting up Julia environment..."
if [ -f "Project.toml" ]; then
    julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()' && echo "✅ Julia environment ready" || echo "⚠️  Julia setup skipped (optional)"
else
    echo "⚠️  Project.toml not found, skipping Julia setup"
fi

# ============================================
# R: Restore renv (if available)
# ============================================
echo "📦 Setting up R environment..."
if [ -f "renv.lock" ]; then
    export R_LIBS_USER="/opt/R-packages"
    Rscript -e 'renv::restore()' && echo "✅ R environment ready" || echo "⚠️  renv::restore() skipped (optional)"
else
    echo "⚠️  renv.lock not found, skipping R package restore"
fi

# ============================================
# Summary
# ============================================
echo ""
echo "════════════════════════════════════════"
echo "✨ Setup Complete!"
echo "════════════════════════════════════════"
echo ""
echo "🐍 Python:  $(python --version)"
echo "📦 Airflow: $(airflow version)"
echo "🧮 Julia:   $(julia --version 2>&1 | head -1)"
echo "📊 R:       $(R --version 2>&1 | head -1)"
echo ""
echo "📝 Next steps:"
echo ""
echo "   1. Export Airflow home (if not already set):"
echo "      export AIRFLOW_HOME=\$(pwd)/airflow"
echo ""
echo "   2. Start Airflow webserver:"
echo "      airflow standalone"
echo ""
echo "   3. Access Airflow UI at: http://localhost:8080"
echo ""
echo "════════════════════════════════════════"
