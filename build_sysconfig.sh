#!/bin/bash

# Using util_functions.sh
[ -f "util_functions.sh" ] && . ./util_functions.sh || { echo "util_functions.sh not found" && exit 1; }

# Start processing directories (default to ./extracted_images)
process_directories "${BASH_SOURCE[0]}" "$1"

# List of files to copy
files_to_copy="nga pixel_experience_ google.xml google_build.xml google_fi.xml adaptivecharging.xml quick_tap.xml"

# Copy specific files
copy_specific_files "$dir/extracted/product/etc/sysconfig" "$dir/system/product/etc/sysconfig/" "$files_to_copy"
