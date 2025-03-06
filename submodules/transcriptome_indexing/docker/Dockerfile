# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set non-interactive mode for apt-get to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies required for building Kallisto
RUN apt-get update && apt-get install -y \
    g++ \
    cmake \
    autoconf \
    automake \
    make \
    zlib1g-dev \
    libhdf5-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory for installation
WORKDIR /opt

# Build Kallisto following official source documentation
RUN git clone https://github.com/pachterlab/kallisto.git
WORKDIR /opt/kallisto/ext/htslib
RUN autoheader &&  autoconf
WORKDIR /opt/kallisto
RUN mkdir build && cd build \
    && cmake .. \
    && make  \
    && make install

# Ensure Kallisto is in the PATH
ENV PATH="/usr/local/bin:$PATH"

# Set the default command to run Kallisto when the container starts
CMD ["kallisto"]