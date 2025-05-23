#!/bin/bash
set -e

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINEPREFIX="$SCRIPT_DIR/sparxea/wineprefix"
WINE_BIN="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin/wine64"
WINETRICKS_PATH="$SCRIPT_DIR/winetricks"

# Set Wine environment variables
export WINEPREFIX="$WINEPREFIX"
export WINEARCH="win64"
export WINE="$WINE_BIN"
export WINESERVER="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin/wineserver"
export PATH="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin:$PATH"

echo "Installing Wine dependencies for Sparx EA..."

# Create Wine prefix directory if it doesn't exist
mkdir -p "$WINEPREFIX"

# Initialize Wine prefix
echo "Initializing Wine prefix..."
"$WINE" wineboot -i

# Apply registry settings for minimal configuration
echo "Applying minimal registry configuration..."
"$WINE" regedit "$SCRIPT_DIR/reg_minimal_config.reg"

echo "Disable winemenubuilder..."
"$WINE" regedit "$SCRIPT_DIR/reg_disable_winemenubuilder.reg"

# Check if winetricks exists and is executable
# if [ ! -f "$WINETRICKS_PATH" ] || [ ! -x "$WINETRICKS_PATH" ]; then
#     echo "Downloading winetricks..."
#     curl -L -o "$WINETRICKS_PATH" "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
#     chmod +x "$WINETRICKS_PATH"
# fi

# Install MSXML3, MSXML4, and MDAC using winetricks
# echo "Installing MSXML3..."
# WINE="$WINE" "$WINETRICKS_PATH" msxml3

# echo "Installing MSXML4..."
# WINE="$WINE" "$WINETRICKS_PATH" msxml4

# echo "Installing MDAC..."
# WINE="$WINE" "$WINETRICKS_PATH" mdac28

# # Install Common Controls
# echo "Installing Common Controls..."
# WINE="$WINE" "$WINETRICKS_PATH" comctl32

# Apply registry settings to disable ODBC
echo "Applying ODBC registry configurations..."
"$WINE" regedit "$SCRIPT_DIR/reg_disable_odbc.reg"
"$WINE" regedit "$SCRIPT_DIR/reg_aggressive_odbc_disable.reg"
"$WINE" regedit "$SCRIPT_DIR/reg_dummy_odbc.reg"

# Apply fix for Common Controls
echo "Applying Common Controls fix..."
"$SCRIPT_DIR/fix_common_controls.sh"

echo "Dependencies installation completed."
