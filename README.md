# Sparx Enterprise Architect Mac App bundle builder

This project creates a MacOS app bundle for Sparx Enterprise Architect with SparxEA and Wine Crossover.

# How to run this project 

1) Download the Sparx EA 64bit installer from https://sparxsystems.com/products/ea/trial/request.html and save it in `sparx_installer` with the name `easetup_x64.msi`
2) Run `build.sh` from the terminal This will create the app bundle and open a finder window on the directory with the built app
3) Have fun running the Sparx EA.

# Warnings

This project is a Proof of Concept. For security purposes, Wine Crossover, Winetricks and related libraries should be assessed against a digest (sha256 or similar).

# Note

The wine menu builder (`winemenubuilder.exe`) could be flagged as malware by certain anti-malware. It has therefore been removed. This should not create issues, as Sparx Enterprise Architect uses a ribbon interface.

