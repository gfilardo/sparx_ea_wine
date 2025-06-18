#!/bin/bash
set -e

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINEPREFIX="$SCRIPT_DIR/sparxea/wineprefix"
WINE_BIN="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin/wine64"
EA_PATH="$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA/EA.exe"

# Set Wine environment variables
export WINEPREFIX="$WINEPREFIX"
export WINEARCH="win64"
export WINE="$WINE_BIN"
export WINESERVER="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin/wineserver"
export PATH="$SCRIPT_DIR/wine/Wine Crossover.app/Contents/Resources/wine/bin:$PATH"

# Set additional environment variables to improve compatibility
export WINEDEBUG="-all"
export WINEESYNC=0
export WINEFSYNC=0
export WINE_LARGE_ADDRESS_AWARE=1
export DXVK_HUD=0
export DXVK_LOG_LEVEL=none

# Run Sparx EA
"$WINE" "$EA_PATH" "$@" 