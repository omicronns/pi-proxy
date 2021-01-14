#!/bin/bash

# Set -e so that if any command fails the script will exit immediately.
set -e

# Install requirements
sudo apt update
sudo apt-get -y install \
  python3 \
  python3-pip

# Install mitmproxy
pip3 install mitmproxy
