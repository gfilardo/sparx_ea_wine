#!/bin/bash

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Clean up existing installation
echo "Cleaning up existing installation..."
rm -rf "$SCRIPT_DIR/sparxea"
rm -rf "$SCRIPT_DIR/bundle"
rm -rf "$SCRIPT_DIR/wine"
rm -f  "$SCRIPT_DIR/winetricks"
rm -rf "$SCRIPT_DIR/sparx_installer"
rm -f  "$SCRIPT_DIR/SparxEA.dmg"

# Set up Wine environment
echo "===================================================="
echo "Setting up Wine Crossover environment..."
echo "===================================================="
"$SCRIPT_DIR/setup_wine.sh"

# Initialize Wine prefix with minimal configuration
echo "===================================================="
echo "Setting up Wine prefix with minimal configuration..."
echo "===================================================="
"$SCRIPT_DIR/install_dependencies.sh"

# Install Sparx EA
echo "===================================================="
echo "Installing Sparx Enterprise Architect..."
echo "===================================================="
"$SCRIPT_DIR/install_sparx.sh"

exit 0;

# Create app bundle with the simplified approach
echo "Creating app bundle..."
"$SCRIPT_DIR/create_simple_bundle.sh"

echo "Rebuild completed."
echo "You can now run Sparx Enterprise Architect using:"
echo "  ./run_sparx_direct.sh"
echo "Or distribute the app bundle from bundle/SparxEA.app" 
