#!/usr/bin/env bash
# Render build script for SKOPOS backend
set -o errexit

python -m pip install --upgrade pip
pip install --no-cache-dir -r requirements.txt
