#!/bin/bash

# Using util_functions.sh
[ -f "util_functions.sh" ] && . ./util_functions.sh || { echo "util_functions.sh not found" && exit 1; }

# At least two arguments: URL and device codename
[ -z "$1" ] || [ -z "$2" ] && print_message "Usage: download_ota_from_url.sh <URL> <device_codename>" error

OTA_URL="$1"
DEVICE_CODENAME="$2"

print_message "Downloading OTA for $DEVICE_CODENAME from $OTA_URL..." info

# Make sure download directory exists
mkdir -p "dl"

# Download using aria2c
aria2c -Z -m0 -x16 -s16 -j16 --file-allocation=none --enable-rpc=false --optimize-concurrent-downloads=true --disable-ipv6=true --allow-overwrite=true --remove-control-file=true --always-resume=true --download-result=full --summary-interval=0 -d ./dl -o "${DEVICE_CODENAME}.zip" "$OTA_URL"

print_message "Download complete" info
