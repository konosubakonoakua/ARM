#!/bin/bash

# Download all images in all markdown files.
# Define the target folder
target_folder="./assets/images"

# Create the target folder if it doesn't exist
mkdir -p "$target_folder"

# Find all markdown files
find . -type f -name "*.md" -print0 | while IFS= read -r -d $'\0' file; do
	# Extract image URLs using grep
	img_urls=$(grep -oP '!\[.*\]\(\K.*(?=\))' "$file")

	# Download each image using wget
	for img_url in $img_urls; do
		echo ">>>>>>>>>$img_url"
		wget -P "$target_folder" "$img_url"
	done
done
