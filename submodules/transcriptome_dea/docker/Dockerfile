# Use an official R base image
FROM r-base

# Install system dependencies required for R packages
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libhdf5-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgit2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install required R packages including Bioconductor and Sleuth
RUN R -e "install.packages('BiocManager', repos='http://cran.rstudio.com/')"

RUN R -e "BiocManager::install('rhdf5')"

RUN R -e "install.packages(c('usethis', 'pkgdown', 'devtools', 'ggplot2', 'dplyr', 'optparse', 'gridExtra'))"

RUN R -e "devtools::install_github('pachterlab/sleuth')"

# Create script directory and copy scripts
WORKDIR /scripts
COPY bin/run_sleuth_analysis.sh /scripts/
COPY bin/sleuth_dea.R /scripts/

# Make scripts executable
RUN chmod +x /scripts/run_sleuth_analysis.sh /scripts/sleuth_dea.R

# Set default command
CMD ["bash"]