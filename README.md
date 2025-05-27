# Sparx Enterprise Architect Mac App bundle builder

This project creates a MacOS app bundle for Sparx Enterprise Architect with SparxEA and Wine Crossover.

Once the bundle is created, it is possible to distribute, install and run it as any other MacOS App, without requiring a globally installed wine, as all the dependencies are within the bundle itself.

The builder uses Wine Crossover v23.7.1_1, and has been tested with Sparx Enterprise Architect Trial v17.1.

# How to run this project 

1) Download the Sparx EA 64bit installer from https://sparxsystems.com/products/ea/trial/request.html and save it in `sparx_installer` with the name `easetup_x64.msi`
2) Run `build.sh` from the terminal This will create the app bundle and open a finder window on the directory with the built app
3) Have fun running the Sparx EA.

# Building a dmg

In order to build a `.dmg` archive, run `./create_dmg.sh` after a successful buid.

# Warnings

This project is a Proof of Concept. For security purposes, Wine Crossover, Winetricks and related libraries should be assessed against a digest (sha256 or similar).

# Note

As wine menu builder (`winemenubuilder.exe`) could be flagged as malware by certain anti-malware, it is not included in the final bundle. This should not create issues, as Sparx Enterprise Architect uses a ribbon interface, and does not require it.

