#!/bin/bash

# Set -e so that if any command fails the script will exit immediately.
set -e

# Install requirements
sudo pacman -Sy python-pip

# Install mitmproxy
pip3 install mitmproxy
