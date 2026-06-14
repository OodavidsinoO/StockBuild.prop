#!/bin/bash

# Using util_functions.sh
[ -f "util_functions.sh" ] && . ./util_functions.sh || { echo "util_functions.sh not found" && exit 1; }

[ -z "$1" ] && print_message "Usage: build_from_url.sh <URL> [device_codename] [device_name]" error

OTA_URL="$1"
DEVICE_CODENAME="${2:-}"
DEVICE_NAME="${3:-}"

print_message "StockBuild: Building module from $OTA_URL..." info

# Download OTA (auto-detects codename if not provided)
./download_ota_from_url.sh "$OTA_URL" "$DEVICE_CODENAME"

# Read resolved codename
DEVICE_CODENAME=$(cat ./dl/.codename)
print_message "Device codename: $DEVICE_CODENAME" info

# Extract and build
./extract_images.sh

print_message "Build complete! Check result/ directory for the module." info
