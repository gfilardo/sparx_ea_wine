#!/bin/bash
set -e

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINEPREFIX="$SCRIPT_DIR/sparxea/wineprefix"
WINE_ROOT="$SCRIPT_DIR/wine/Wine Staging.app/Contents/Resources/wine"
WINE_BIN="$WINE_ROOT/bin/wine"
EA_PATH="$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA/EA.exe"

# Set Wine environment variables
export WINEPREFIX="$WINEPREFIX"
export WINEARCH="win64"
export WINE="$WINE_BIN"
export WINELOADER="$WINE_BIN"
export WINESERVER="$WINE_ROOT/bin/wineserver"
export WINEDLLPATH="$WINE_ROOT/lib/wine"
export DYLD_FALLBACK_LIBRARY_PATH="$WINE_ROOT/lib:$DYLD_FALLBACK_LIBRARY_PATH"
export PATH="$WINE_ROOT/bin:$PATH"

# Set additional environment variables to improve compatibility
export WINEDEBUG="-all"
export WINEESYNC=0
export WINEFSYNC=0
export WINE_LARGE_ADDRESS_AWARE=1
export DXVK_HUD=0
export DXVK_LOG_LEVEL=none

# Run Sparx EA
"$WINE_BIN" "$EA_PATH" "$@"