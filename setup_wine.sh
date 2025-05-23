#!/bin/bash
set -e

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINE_DIR="$SCRIPT_DIR/wine"
WINE_SHA256SUM="e24ba084737c8823e8439f7cb75d436a917fd92fc34b832bcaa0c0037eb33d03"

echo "Downloading Wine..."
    
# Create Wine directory if it doesn't exist
mkdir -p "$WINE_DIR"

# Use Homebrew version of Wine-Crossover
echo "Downloading Wine Crossover from GitHub release..."
WINE_RELEASE_URL="https://github.com/Gcenx/winecx/releases/download/crossover-wine-23.7.1-1/wine-crossover-23.7.1-1-osx64.tar.xz"
WINE_DOWNLOAD_PATH="/tmp/wine-crossover.tar.xz"

# Download Wine
curl -L -o "$WINE_DOWNLOAD_PATH" "$WINE_RELEASE_URL"

#TODO check sha256sum

# Extract Wine to our directory
echo "Extracting Wine package..."
mkdir -p "/tmp/wine_extract"
tar -xf "$WINE_DOWNLOAD_PATH" --exclude winemenubuilder.exe -C "/tmp/wine_extract"

# Copy the extracted files to our Wine directory
echo "Installing Wine..."
cp -R "/tmp/wine_extract"/* "$WINE_DIR/"

# Remove winemenubuilder.exe to prevent issues
echo "Removing winemenubuilder.exe..."
find "$WINE_DIR" -name "winemenubuilder.exe" -exec rm -f {} \;

# Clean up
rm -rf "/tmp/wine_extract"
rm "$WINE_DOWNLOAD_PATH"

echo "Wine binaries downloaded and installed. Setup completed."
