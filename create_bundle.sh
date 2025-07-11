#!/bin/bash

# Set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_DIR="$SCRIPT_DIR/bundle/SparxEA.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
MACOS_DIR="$CONTENTS_DIR/MacOS"

# Create bundle directory structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR/sparxea"
mkdir -p "$RESOURCES_DIR/config"
mkdir -p "$RESOURCES_DIR/wine"

# Make sure Sparx EA is installed
if [ ! -f "$SCRIPT_DIR/sparxea/wineprefix/drive_c/Program Files/Sparx Systems/EA/EA.exe" ]; then
  echo "Error: Enterprise Architect does not appear to be installed correctly."
  echo "Please run ./install_sparx.sh first."
  exit 1
fi

# Copy config files to bundle
cp "$SCRIPT_DIR/reg_minimal_config.reg" "$RESOURCES_DIR/config/"
cp "$SCRIPT_DIR/reg_fix_common_controls.sh" "$RESOURCES_DIR/config/"
cp "$SCRIPT_DIR/reg_disable_odbc.reg" "$RESOURCES_DIR/config/"
cp "$SCRIPT_DIR/reg_aggressive_odbc_disable.reg" "$RESOURCES_DIR/config/"

# Create dummy_odbc.reg file
cat > "$RESOURCES_DIR/config/reg_dummy_odbc.reg" << EOF
REGEDIT4

; Make Wine use its built-in ODBC32 libraries rather than looking for Windows ones
[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"odbc32"="builtin"
"odbccp32"="builtin"
"odbccu32"="builtin"
"odbcbcp"="builtin"
"msado15"="builtin" 
"msdasql"="builtin"
"sqlsrv32"="builtin"
"msdaer"="builtin"
"msdaenum"="builtin"
"msdadiag"="builtin"
"msdasc"="builtin"
"msdart"="builtin"
EOF

# Create EA specific DLL overrides
cat > "$RESOURCES_DIR/config/ea_specific_overrides.reg" << EOF
REGEDIT4

[HKEY_CURRENT_USER\\Software\\Wine\\AppDefaults\\EA.exe\\DllOverrides]
"odbc32"="builtin"
"odbccp32"="builtin"
"odbccu32"="builtin"
"odbcbcp"="builtin"
"msado15"="builtin"
"msdasql"="builtin"
"sqlsrv32"="builtin"
"msdaer"="builtin"
"msdaenum"="builtin"
"msdadiag"="builtin"
"msdasc"="builtin"
"msdart"="builtin"
"comctl32"="native,builtin"
"uxtheme"="native,builtin"
EOF

# Copy Wine from the downloaded archive
echo "Copying Wine..."
# Create the correct directory structure
mkdir -p "$RESOURCES_DIR/wine/bin"

# Copy the Wine binaries directly to the bin directory
cp -R "$SCRIPT_DIR/wine/Wine Stable.app/Contents/Resources/wine/bin/"* "$RESOURCES_DIR/wine/bin/"
# Copy other Wine directories
cp -R "$SCRIPT_DIR/wine/Wine Stable.app/Contents/Resources/wine/lib" "$RESOURCES_DIR/wine/"
cp -R "$SCRIPT_DIR/wine/Wine Stable.app/Contents/Resources/wine/share" "$RESOURCES_DIR/wine/"
cp -R "$SCRIPT_DIR/wine/Wine Stable.app/Contents/Resources/wine/include" "$RESOURCES_DIR/wine/" 2>/dev/null || true

# Copy Sparx EA wineprefix
echo "Copying Sparx EA..."
cp -R "$SCRIPT_DIR/sparxea/wineprefix" "$RESOURCES_DIR/sparxea/"

# Create no_odbc.ini file
mkdir -p "$RESOURCES_DIR/sparxea/wineprefix/drive_c/Program Files/Sparx Systems/EA"
cat > "$RESOURCES_DIR/sparxea/wineprefix/drive_c/Program Files/Sparx Systems/EA/no_odbc.ini" << EOF
[DATABASE]
JET4=[JET 4.0]
MYSQL=[MySQL]
ORACLE=[Oracle]
POSTGRES=[PostgreSQL]
PROGRESS=[Progress]
ACCESS2007=[Access 2007]
FIREBIRD=[Firebird]
Adaptive Server Anywhere=[Sybase Adaptive Server Anywhere]
EA_NO_ODBC=1
EOF

# Create dummy ODBC DLLs
mkdir -p "$RESOURCES_DIR/sparxea/wineprefix/drive_c/windows/system32"
touch "$RESOURCES_DIR/sparxea/wineprefix/drive_c/windows/system32/odbc32.dll"
touch "$RESOURCES_DIR/sparxea/wineprefix/drive_c/windows/system32/odbccp32.dll"

# Create a Windows batch file to launch EA with -no_odbc flag
cat > "$RESOURCES_DIR/sparxea/wineprefix/drive_c/ea_launcher.bat" << EOF
@echo off
set EA_NO_ODBC=1
set DISABLE_ODBC=1
cd "C:\Program Files\Sparx Systems\EA\"
"C:\Program Files\Sparx Systems\EA\EA.exe" -no_odbc
EOF

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SparxEA</string>
    <key>CFBundleIconFile</key>
    <string>SparxEA.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.sparxsystems.ea</string>
    <key>CFBundleName</key>
    <string>Sparx Enterprise Architect</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create executable
cat > "$MACOS_DIR/SparxEA" << EOF
#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
RESOURCES_DIR="\${SCRIPT_DIR}/../Resources"
LOG_FILE="\$HOME/sparxea_debug.log"

# Make sure we use English language
export LC_ALL=C

# Start logging
exec > >(tee -a "\$LOG_FILE") 2>&1
echo "\$(date): Starting Sparx EA launcher..."
echo "Script directory: \$SCRIPT_DIR"
echo "Resources directory: \$RESOURCES_DIR"

# Set up environment
export WINEPREFIX="\$RESOURCES_DIR/sparxea/wineprefix"
export WINEDEBUG="-all"  # Disable all debugging to reduce log size
export WINEARCH=win64
export WINEESYNC=1
export vblank_mode=0
export DYLD_FALLBACK_LIBRARY_PATH="\$RESOURCES_DIR/wine/lib:\$DYLD_FALLBACK_LIBRARY_PATH"

# Use a special variable to indicate no ODBC
export EA_NO_ODBC=1
export DISABLE_ODBC=1

echo "Environment variables set:"
echo "WINEPREFIX=\$WINEPREFIX"
echo "WINEARCH=\$WINEARCH"

# Path to wine executable - use the corrected path
WINE_PATH="\$RESOURCES_DIR/wine/bin/wine"
echo "Wine path: \$WINE_PATH"

# Check if Wine executable exists
if [ ! -f "\$WINE_PATH" ]; then
  echo "ERROR: Wine executable not found at \$WINE_PATH"
  echo "Contents of wine directory:"
  ls -la "\$RESOURCES_DIR/wine"
  echo "Contents of bin directory:"
  ls -la "\$RESOURCES_DIR/wine/bin" 2>/dev/null || echo "Bin directory not found"
  exit 1
fi

# Check if wineprefix exists
if [ ! -d "\$WINEPREFIX" ]; then
  echo "ERROR: Wine prefix not found at \$WINEPREFIX"
  echo "Contents of Resources directory:"
  ls -la "\$RESOURCES_DIR"
  exit 1
fi

# Create an empty dummy ODBC32.dll if it doesn't exist
if [ ! -f "\$WINEPREFIX/drive_c/windows/system32/odbc32.dll" ]; then
  echo "Creating dummy ODBC DLLs..."
  mkdir -p "\$WINEPREFIX/drive_c/windows/system32"
  touch "\$WINEPREFIX/drive_c/windows/system32/odbc32.dll"
  touch "\$WINEPREFIX/drive_c/windows/system32/odbccp32.dll"
fi

# Apply configurations
echo "Applying registry configurations..."
"\$WINE_PATH" regedit /S "\$RESOURCES_DIR/config/reg_minimal_config.reg" > /dev/null 2>&1 || echo "Error applying minimal_config.reg"
"\$WINE_PATH" regedit /S "\$RESOURCES_DIR/config/reg_disable_odbc.reg" > /dev/null 2>&1 || echo "Error applying disable_odbc.reg"
"\$WINE_PATH" regedit /S "\$RESOURCES_DIR/config/reg_aggressive_odbc_disable.reg" > /dev/null 2>&1 || echo "Error applying aggressive_odbc_disable.reg"
"\$WINE_PATH" regedit /S "\$RESOURCES_DIR/config/reg_dummy_odbc.reg" > /dev/null 2>&1 || echo "Error applying dummy_odbc.reg"
"\$WINE_PATH" regedit /S "\$RESOURCES_DIR/config/ea_specific_overrides.reg" > /dev/null 2>&1 || echo "Error applying ea_specific_overrides.reg"
"\$WINE_PATH" regedit /S "\$RESOURCES_DIR/config/reg_disable_winemenubuilder.reg" > /dev/null 2>&1 || echo "Error applying reg_disable_winemenubuilder.reg"

# Create a config file to disable ODBC if it doesn't exist
if [ ! -f "\$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA/no_odbc.ini" ]; then
  echo "Creating no_odbc.ini file..."
  mkdir -p "\$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA"
  cat > "\$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA/no_odbc.ini" << EOT
[DATABASE]
JET4=[JET 4.0]
MYSQL=[MySQL]
ORACLE=[Oracle]
POSTGRES=[PostgreSQL]
PROGRESS=[Progress]
ACCESS2007=[Access 2007]
FIREBIRD=[Firebird]
Adaptive Server Anywhere=[Sybase Adaptive Server Anywhere]
EA_NO_ODBC=1
EOT
fi

# Create EA.exe.manifest if it doesn't exist
if [ ! -f "\$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA/EA.exe.manifest" ]; then
  echo "Creating EA.exe manifest..."
  mkdir -p "\$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA"
  cat > "\$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA/EA.exe.manifest" << EOT
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="amd64" publicKeyToken="6595b64144ccf1df" language="*" />
  <dependency>
    <dependentAssembly>
      <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="*" publicKeyToken="6595b64144ccf1df" language="*" />
    </dependentAssembly>
  </dependency>
</assembly>
EOT
fi

# Create a wrapper script to launch EA.exe if it doesn't exist
if [ ! -f "\$WINEPREFIX/drive_c/ea_launcher.bat" ]; then
  cat > "\$WINEPREFIX/drive_c/ea_launcher.bat" << EOT
@echo off
set EA_NO_ODBC=1
set DISABLE_ODBC=1
cd "C:\\Program Files\\Sparx Systems\\EA\\"
"C:\\Program Files\\Sparx Systems\\EA\\EA.exe" -no_odbc
EOT
fi

# Fix Common Controls manifest
echo "Applying Common Controls manifest..."
SCRIPT_DIR_BACKUP="\$SCRIPT_DIR"
cd "\$RESOURCES_DIR/config"
bash ./fix_common_controls.sh >> "\$LOG_FILE" 2>&1 || echo "Error running fix_common_controls.sh"
cd "\$SCRIPT_DIR_BACKUP"

# Run Enterprise Architect
echo "Starting Enterprise Architect..."
cd "\$WINEPREFIX/drive_c"
"\$WINE_PATH" cmd /c ea_launcher.bat
EXIT_CODE=\$?
echo "Enterprise Architect exited with code: \$EXIT_CODE"

if [ \$EXIT_CODE -ne 0 ]; then
  echo "Enterprise Architect failed to start. Check \$LOG_FILE for details."
  echo "Last few lines of error log:"
  tail -n 50 "\$LOG_FILE"
fi
EOF

# Make the executable file executable
chmod +x "$MACOS_DIR/SparxEA"

# Update the fix_common_controls.sh script for correct paths
cat > "$RESOURCES_DIR/config/fix_common_controls.sh" << EOF
#!/bin/bash

# Enable error tracing
set -e

# Set paths
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
echo "fix_common_controls.sh running from: \$SCRIPT_DIR"

# WINE_PATH needs to be one level up from config directory
WINE_PATH="\$SCRIPT_DIR/../wine/bin/wine"
WINEPREFIX="\$SCRIPT_DIR/../sparxea/wineprefix"

echo "Wine path: \$WINE_PATH"
echo "Wine prefix: \$WINEPREFIX"

# Check if the Wine executable exists
if [ ! -f "\$WINE_PATH" ]; then
  echo "ERROR: Wine executable not found at \$WINE_PATH"
  echo "Listing wine/bin directory:"
  ls -la "\$(dirname "\$WINE_PATH")" 2>/dev/null || echo "Directory not found"
  exit 1
fi

# Check if Wine prefix exists
if [ ! -d "\$WINEPREFIX" ]; then
  echo "ERROR: Wine prefix not found at \$WINEPREFIX"
  echo "Listing parent directory:"
  ls -la "\$(dirname "\$WINEPREFIX")" 2>/dev/null || echo "Directory not found"
  exit 1
fi

# Set up Wine environment
export WINEPREFIX="\$WINEPREFIX"

# Create directories for manifests
echo "Creating manifests directory..."
mkdir -p "\$WINEPREFIX/drive_c/windows/winsxs/manifests"

# Create the Common Controls manifest file
echo "Creating x86 manifest file..."
cat > "\$WINEPREFIX/drive_c/windows/winsxs/manifests/x86_microsoft.windows.common-controls_6595b64144ccf1df_6.0.2600.2982_none_deadbeef.manifest" << EOT
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
    <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="x86" publicKeyToken="6595b64144ccf1df" language="*" />
</assembly>
EOT

# Create a 64-bit version too
echo "Creating amd64 manifest file..."
cat > "\$WINEPREFIX/drive_c/windows/winsxs/manifests/amd64_microsoft.windows.common-controls_6595b64144ccf1df_6.0.2600.2982_none_deadbeef.manifest" << EOT
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
    <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="amd64" publicKeyToken="6595b64144ccf1df" language="*" />
</assembly>
EOT

# Also create a direct manifest for EA.exe
echo "Creating EA.exe manifest..."
mkdir -p "\$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA"
cat > "\$WINEPREFIX/drive_c/Program Files/Sparx Systems/EA/EA.exe.manifest" << EOT
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="amd64" publicKeyToken="6595b64144ccf1df" language="*" />
  <dependency>
    <dependentAssembly>
      <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="*" publicKeyToken="6595b64144ccf1df" language="*" />
    </dependentAssembly>
  </dependency>
</assembly>
EOT

# Create a global application manifest
echo "Creating Windows manifest..."
cat > "\$WINEPREFIX/drive_c/windows/winsxs/manifests/win32_microsoft.windows.common-controls_6595b64144ccf1df_6.0.2600.2982_none_deadbeef.manifest" << EOT
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
    <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="*" publicKeyToken="6595b64144ccf1df" language="*" />
</assembly>
EOT

echo "Common Controls manifest files have been created."

# Create registry entries for the manifests
echo "Creating registry entries..."
cat > "\$SCRIPT_DIR/manifests.reg" << EOT
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\SideBySide\\\\Winners\\\\x86_microsoft.windows.common-controls_6595b64144ccf1df_6.0.0.0_none]
"6.0.2600.2982"="x86_microsoft.windows.common-controls_6595b64144ccf1df_6.0.2600.2982_none_deadbeef"

[HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\SideBySide\\\\Winners\\\\amd64_microsoft.windows.common-controls_6595b64144ccf1df_6.0.0.0_none]
"6.0.2600.2982"="amd64_microsoft.windows.common-controls_6595b64144ccf1df_6.0.2600.2982_none_deadbeef"

[HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\SideBySide\\\\Winners\\\\win32_microsoft.windows.common-controls_6595b64144ccf1df_6.0.0.0_none]
"6.0.2600.2982"="win32_microsoft.windows.common-controls_6595b64144ccf1df_6.0.2600.2982_none_deadbeef"
EOT

# Import the registry file
echo "Importing registry entries..."
"\$WINE_PATH" regedit /S "\$SCRIPT_DIR/manifests.reg"
echo "Registry import completed with status: \$?"
rm "\$SCRIPT_DIR/manifests.reg"

echo "Common Controls manifest registry entries have been created."

# Also add direct imports to the EA.exe key
cat > "\$SCRIPT_DIR/ea_imports.reg" << EOT
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\\\\Software\\\\Wine\\\\AppDefaults\\\\EA.exe\\\\DllOverrides]
"comctl32"="native,builtin"
"uxtheme"="native,builtin"
EOT

# Import the registry file
echo "Importing EA-specific registry entries..."
"\$WINE_PATH" regedit /S "\$SCRIPT_DIR/ea_imports.reg"
echo "EA registry import completed with status: \$?"
rm "\$SCRIPT_DIR/ea_imports.reg"

echo "All Common Controls configuration completed successfully."
EOF

# Make the script executable
chmod +x "$RESOURCES_DIR/config/fix_common_controls.sh"

# Create additional override for winemenubuilder
cat > "$RESOURCES_DIR/config/reg_disable_winemenubuilder.reg" << EOF
REGEDIT4

[HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides]
"winemenubuilder.exe"=""
EOF

echo "App bundle created at $BUNDLE_DIR"
echo "To use, copy the entire SparxEA.app folder to your Applications directory or distribute it." 