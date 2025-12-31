FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install additional tools
RUN apt-get update && apt-get install -y \
    jq \
    yq \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set locale for German support
RUN apt-get update && apt-get install -y locales \
    && locale-gen de_DE.UTF-8 \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create workspace
WORKDIR /workspace
