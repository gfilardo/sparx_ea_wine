#!/bin/bash
set -e

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINEPREFIX="$SCRIPT_DIR/sparxea/wineprefix"
WINE_ROOT="$SCRIPT_DIR/wine/Wine Staging.app/Contents/Resources/wine"
WINE_BIN="$WINE_ROOT/bin/wine"
WINETRICKS_PATH="$SCRIPT_DIR/winetricks"

# Set Wine environment variables
export WINEPREFIX="$WINEPREFIX"
export WINEARCH="win64"
export WINE="$WINE_BIN"
export WINELOADER="$WINE_BIN"
export WINESERVER="$WINE_ROOT/bin/wineserver"
export WINEDLLPATH="$WINE_ROOT/lib/wine"
export DYLD_FALLBACK_LIBRARY_PATH="$WINE_ROOT/lib:$DYLD_FALLBACK_LIBRARY_PATH"
export PATH="$WINE_ROOT/bin:$PATH"

echo "Configure Wine and its dependencies for Sparx EA..."

# Kill any stale wineserver from a previous run
"$WINESERVER" -k 2>/dev/null || true
sleep 1

# Create Wine prefix directory if it doesn't exist
mkdir -p "$WINEPREFIX"

# Initialize Wine prefix.
# Notes:
#   - Do NOT use `wineboot -i`: on macOS it hangs waiting for services
#     (MountMgr, Eventlog, winebus) that will never fully start.
#   - Run wineboot in the background; wait up to 30s for it to exit on its
#     own, then kill anything still running. The prefix is usable by then.
echo "Initializing Wine prefix..."
WINEDEBUG=-all "$WINE" wineboot &
BOOT_PID=$!
for _ in $(seq 1 30); do
    sleep 1
    kill -0 "$BOOT_PID" 2>/dev/null || break
done
kill "$BOOT_PID" 2>/dev/null || true
"$WINESERVER" -k 2>/dev/null || true
sleep 2

export WINEDEBUG=-all

# Apply registry settings for minimal configuration
echo "Applying minimal registry configuration..."
"$WINE" regedit /S "$SCRIPT_DIR/reg_minimal_config.reg"

echo "Disable winemenubuilder..."
"$WINE" regedit /S "$SCRIPT_DIR/reg_disable_winemenubuilder.reg"

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
"$WINE" regedit /S "$SCRIPT_DIR/reg_disable_odbc.reg"
"$WINE" regedit /S "$SCRIPT_DIR/reg_aggressive_odbc_disable.reg"
"$WINE" regedit /S "$SCRIPT_DIR/reg_dummy_odbc.reg"

# Shut down wineserver cleanly before the next step
"$WINESERVER" -w

echo "Dependencies installation completed."
