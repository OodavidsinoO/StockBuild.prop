#!/bin/bash

# Using util_functions.sh
[ -f "util_functions.sh" ] && . ./util_functions.sh || { echo "util_functions.sh not found" && exit 1; }

# At least one argument: URL
[ -z "$1" ] && print_message "Usage: download_ota_from_url.sh <URL> [device_codename]" error

OTA_URL="$1"
DEVICE_CODENAME="$2"

print_message "Downloading OTA for ${DEVICE_CODENAME:-auto-detect} from $OTA_URL..." info

# Make sure download directory exists
mkdir -p "dl"

# Download to an isolated temp dir to avoid conflicts and filename guessing
# (aria2c may use Content-Disposition header instead of -o flag)
TEMP_DL_DIR="dl/.tmp_dl_$$"
mkdir -p "$TEMP_DL_DIR"
aria2c -Z -m0 -x16 -s16 -j16 --file-allocation=none --enable-rpc=false --optimize-concurrent-downloads=true --disable-ipv6=true --allow-overwrite=true --remove-control-file=true --always-resume=true --download-result=full --summary-interval=0 -d "$TEMP_DL_DIR" "$OTA_URL"

# Find the downloaded file (isolated dir, should be exactly one)
DOWNLOADED_FILE=$(find "$TEMP_DL_DIR" -maxdepth 1 -type f -print -quit)
[ -z "$DOWNLOADED_FILE" ] && print_message "Download failed: no file found in $TEMP_DL_DIR" error

# Auto-detect codename from metadata if not provided
if [ -z "$DEVICE_CODENAME" ]; then
	print_message "Auto-detecting device codename from OTA metadata..." info

	DEVICE_CODENAME=$(python3 -c "
import zipfile
with zipfile.ZipFile('$DOWNLOADED_FILE', 'r') as z:
    meta = z.read('META-INF/com/android/metadata').decode('utf-8', errors='replace')
for line in meta.strip().split('\n'):
    if line.startswith('pre-device='):
        print(line.split('=', 1)[1])
        break
" 2>/dev/null)

	if [ -z "$DEVICE_CODENAME" ]; then
		print_message "Could not auto-detect device codename from OTA metadata. Please provide it manually as the second argument." error
	fi

	print_message "Detected device codename: $DEVICE_CODENAME" info
fi

# Save resolved codename for caller
echo "$DEVICE_CODENAME" > dl/.codename

# Move to final location
mv -f "$DOWNLOADED_FILE" "dl/${DEVICE_CODENAME}.zip"
rm -rf "$TEMP_DL_DIR"

print_message "Download complete: dl/${DEVICE_CODENAME}.zip" info
