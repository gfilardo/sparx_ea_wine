# Sparx Enterprise Architect Mac App bundle builder

This project creates a MacOS app bundle for Sparx Enterprise Architect with SparxEA and Wine Staging.

Once the bundle is created, it is possible to distribute, install and run it as any other MacOS App, without requiring a globally installed wine, as all the dependencies are within the bundle itself.

The builder uses **Wine Staging 11.7** (from [Gcenx macOS Wine builds](https://github.com/Gcenx/macOS_Wine_builds)), and has been tested with **Sparx Enterprise Architect Trial v17.1** and **Sparx Enterprise Architect Full v17.1**.

On Apple Silicon Macs (M1/M2/M3/M4), the x86_64 Wine binary runs via Rosetta 2, which must be installed.

# How to run this project

1) Place the 64bit installer for either the trial or the full version within the `sparx_installer` directory, with the name `easetup_x64.msi`. The trial version can be downloaded from https://sparxsystems.com/products/ea/trial/request.html
2) Run `build.sh` from the terminal. This will create the app bundle and open a finder window on the directory with the built app.
3) Have fun running Sparx EA.

# Building a dmg

In order to build a `.dmg` archive, run `./create_dmg.sh` after a successful build. The `SparxEA.dmg` file will be created in the project root.

# Notes

+ The project downloads Wine Staging from GitHub. To ensure that the archive is not corrupted or tampered with, it is verified against a SHA256 digest. To update to a new version, update both the archive URI and the digest in `config.sh`.

+ As wine menu builder (`winemenubuilder.exe`) could be mistakenly flagged as malware by certain anti-malware, it is excluded from the final bundle. This won't create issues, as Sparx Enterprise Architect uses a ribbon interface and does not require it.

+ The generated bundle has been tested to work on Archimate diagrams from a cloud repository. Other use cases have not been tested and might require additional configuration — e.g. ODBC drivers, msxml3, msxml4, mdac28 etc.
Refer to the [SparxSystems documentation](https://sparxsystems.com/enterprise_architect_user_guide/17.1/getting_started/install_ea_wine.html) to address other use cases.

