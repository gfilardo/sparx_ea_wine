#!/bin/bash
set -e

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINEPREFIX="$SCRIPT_DIR/sparxea/wineprefix"
WINE_BIN="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin/wine64"
MSI_INSTALLER_DIR="$SCRIPT_DIR/sparx_installer"
MSI_INSTALLER_FILE="$MSI_INSTALLER_DIR/easetup_x64.msi"

# Set Wine environment variables
export WINEPREFIX="$WINEPREFIX"
export WINEARCH="win64"
export WINE="$WINE_BIN"
export WINESERVER="$SCRIPT_DIR/wine/bin/wineserver"
export PATH="$SCRIPT_DIR/wine/bin:$PATH"

# Create MSI installer directory if it doesn't exist
mkdir -p "$MSI_INSTALLER_DIR"

# Use Homebrew version of Wine-Crossover
echo "Downloading Sparx Enterprise Architect installer..."
MSI_DOWNLOAD_URL="https://sparxsystems.com/products/ea/trial/easetup_x64.msi"

# Download Wine
curl -L -o "$MSI_INSTALLER_FILE" "$MSI_DOWNLOAD_URL"

echo "Installing Sparx Enterprise Architect..."

# Verify that the MSI installer exists
if [ ! -f "$MSI_INSTALLER_FILE" ]; then
    echo "Error: Sparx Enterprise Architect installer not found at $MSI_INSTALLER"
    echo "Please download the installer and place it in the script directory."
    echo "You can download it from: https://sparxsystems.com/products/ea/trial/easetup_x64.msi"
    exit 1
fi

# Install Sparx EA using Wine's msiexec
echo "Running MSI installer..."
"$WINE" msiexec /i "$MSI_INSTALLER_FILE" /quiet /norestart

echo "Creating shortcut in Wine desktop..."
ln -sf "$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA Trial/EA.exe" "$WINEPREFIX/drive_c/users/Public/Desktop/Enterprise Architect.lnk"

echo "Sparx Enterprise Architect installation completed." 