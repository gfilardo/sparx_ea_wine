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
export WINESERVER="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin/wineserver"
export PATH="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin:$PATH"

# Create MSI installer directory if it doesn't exist
mkdir -p "$MSI_INSTALLER_DIR"

echo "Installing Sparx Enterprise Architect..."

# Verify that the MSI installer exists
if [ ! -f "$MSI_INSTALLER_FILE" ]; then
    echo "Error: Sparx Enterprise Architect installer not found at $MSI_INSTALLER_FILE"
    echo "Please manually download the installer from the Sparx Systems website and place it in the $MSI_INSTALLER_DIR directory."
    echo "Download URL: https://sparxsystems.com/bin/easetup_x64.msi"
    echo "Note: You may need to register for a trial on their website first."
    exit 1
fi

# Install Sparx EA using Wine's msiexec
echo "Running MSI installer..."
"$WINE" msiexec /i "$MSI_INSTALLER_FILE" /quiet /norestart

echo "Creating shortcut in Wine desktop..."
ln -sf "$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA Trial/EA.exe" "$WINEPREFIX/drive_c/users/Public/Desktop/Enterprise Architect.lnk"

echo "Sparx Enterprise Architect installation completed." 