#!/bin/bash
set -e

echo "📈 [3/3] Setting up R Environment..."

# Verify R version
R_VER=$(Rscript -e 'cat(paste0(R.version$major, ".", R.version$minor))')
echo "   Active R Version: $R_VER"

echo "📦 Initializing renv..."

Rscript -e "
if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv')

# 1. Configure Binary Repos (Bookworm)
options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/bookworm/latest'))

# 2. Initialize with Ignored Packages
# This tells renv: 'Pretend these packages don't exist. Never install them.'
renv::init(
    bare = FALSE, 
    restart = FALSE, 
    force = TRUE, 
    settings = list(ignored.packages = c('sf', 'units', 'terra', 'raster', 'sp', 'rgdal'))
)

# 3. Hydrate (Install everything else)
renv::hydrate(update = TRUE)
"

echo "✅ R Setup Complete."
