#!/bin/bash
set -e

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINEPREFIX="$SCRIPT_DIR/sparxea/wineprefix"
WINE_ROOT="$SCRIPT_DIR/wine/Wine Staging.app/Contents/Resources/wine"
WINE_BIN="$WINE_ROOT/bin/wine"
MSI_INSTALLER_DIR="$SCRIPT_DIR/sparx_installer"
MSI_INSTALLER_FILE="$MSI_INSTALLER_DIR/easetup_x64.msi"

# Set Wine environment variables
export WINEPREFIX="$WINEPREFIX"
export WINEARCH="win64"
export WINE="$WINE_BIN"
export WINELOADER="$WINE_BIN"
export WINESERVER="$WINE_ROOT/bin/wineserver"
export WINEDLLPATH="$WINE_ROOT/lib/wine"
export DYLD_FALLBACK_LIBRARY_PATH="$WINE_ROOT/lib:$DYLD_FALLBACK_LIBRARY_PATH"
export PATH="$WINE_ROOT/bin:$PATH"
export WINEDEBUG=-all

# Create MSI installer directory if it doesn't exist
mkdir -p "$MSI_INSTALLER_DIR"

echo "Installing Sparx Enterprise Architect..."

# Verify that the MSI installer exists
if [ ! -f "$MSI_INSTALLER_FILE" ]; then
    echo "Error: Sparx Enterprise Architect installer not found at $MSI_INSTALLER_FILE"
    echo "Please manually place the installer in the $MSI_INSTALLER_DIR directory with the name easetup_x64.msi"
    echo "The installer for the Trial version can be downloaded from the Sparx Systems website."
    echo "Download URL: https://sparxsystems.com/bin/easetup_x64.msi"
    echo "Note: You may need to register for a trial on their website first."
    exit 1
fi

# Install Sparx EA using Wine's msiexec
echo "Running MSI installer..."
MSI_LOG="/tmp/sparxea_msi_install.log"
set +e
"$WINE_BIN" msiexec /i "$MSI_INSTALLER_FILE" /norestart "/l*v" "$MSI_LOG"
MSI_EXIT=$?
set -e
# 0 = success, 3010 = success but restart needed, 1641 = success and reboot initiated
if [ "$MSI_EXIT" -ne 0 ] && [ "$MSI_EXIT" -ne 3010 ] && [ "$MSI_EXIT" -ne 1641 ]; then
    echo "ERROR: MSI installer failed with exit code $MSI_EXIT. Log: $MSI_LOG"
    tail -50 "$MSI_LOG" 2>/dev/null
    exit 1
fi

# in order to support both the trial and the full version, rename the trial 
# installation directory to the full version directory
TRIAL_DIR="$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA Trial"
FULL_DIR="$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA"

# The trial version installer does not support the /d command line parameter
# to specify the installation directory. Moving the installation manually, instead.
if [ -d "$TRIAL_DIR" ] && [ ! -d "$FULL_DIR" ]; then
    echo "Renaming trial installation directory to full version directory..."
    mv "$TRIAL_DIR" "$FULL_DIR"
fi

echo "Creating shortcut in Wine desktop..."
ln -sf "$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA/EA.exe" "$WINEPREFIX/drive_c/users/Public/Desktop/Enterprise Architect.lnk"

# Shut down wineserver cleanly before the next step
"$WINESERVER" -w

echo "Sparx Enterprise Architect installation completed."