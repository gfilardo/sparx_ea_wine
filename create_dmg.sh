#!/bin/bash
set -e

# Configuration
APP_NAME="SparxEA"
DMG_NAME="${APP_NAME}"
SOURCE_DIR="bundle/${APP_NAME}.app"
DMG_PATH="${DMG_NAME}.dmg"
VOLUME_NAME="${APP_NAME}"
TEMP_DMG="temp_${DMG_NAME}.dmg"

# Ensure source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist!"
    exit 1
fi

echo "Creating DMG for $APP_NAME..."

# Remove existing DMG if it exists
if [ -f "$DMG_PATH" ]; then
    echo "Removing existing DMG..."
    rm "$DMG_PATH"
fi

# Create temporary DMG
echo "Creating temporary DMG..."
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$SOURCE_DIR" -ov -format UDRW "$TEMP_DMG"

# Convert to compressed DMG
echo "Converting to compressed DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -o "$DMG_PATH"

# Clean up
echo "Cleaning up..."
rm "$TEMP_DMG"

echo "DMG creation complete: $DMG_PATH"
echo "Size: $(du -h "$DMG_PATH" | cut -f1)" 