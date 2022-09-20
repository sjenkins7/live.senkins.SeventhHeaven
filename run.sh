#!/bin/sh
set -euo pipefail

# Don't let wine prompt for mono
WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init

winetricks d3dx9 -q
winetricks msls31 -q
winetricks riched20 -q
winetricks corefonts -q
winetricks d3dcompiler_43 -q
winetricks d3dcompiler_47 -q

#! FIXME - these winetricks installs aren't actually quiet - might need to tackle these manually...
winetricks vcrun2019 -q 
winetricks dotnet48 -q

# Download and install 7th Heaven into prefix
wine /app/extra/7thHeaven-v2.6.1.0_Release.exe /VERYSILENT

# Setup Virtual Disc
mkdir -p "${WINEPREFIX}/drive_c/FF7DISC1"
echo "FF7DISC1" > "${WINEPREFIX}/drive_c/FF7DISC1/.windows-label"
echo "44000000" > "${WINEPREFIX}/drive_c/FF7DISC1/.windows-serial"
touch "${WINEPREFIX}/drive_c/FF7DISC1/FF7DISC1.TXT"
rm -f "${WINEPREFIX}/dosdevices/x:"
ln -sv "../drive_c/FF7DISC1/" "${WINEPREFIX}/dosdevices/x:"

# Install VKD3D
TMPDIR=$(mktemp -d)
tar -xvf /app/extra/vkd3d-proton-2.6.tar.zst -C "${TMPDIR}" --strip=1
"${TMPDIR}/setup_vkd3d_proton.sh" install
rm -rf "${TMPDIR}"

# Pull FF7 from Steam
#! FIXME - what if its not in the default location?
if [ ! -f "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FF7_Launcher.exe" ]
then
    rm -rf "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/"
    mkdir -p "${WINEPREFIX}/drive_c/Games/"
    cp -r ~/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/common/FINAL\ FANTASY\ VII/ "${WINEPREFIX}/drive_c/Games/"
fi

# Ensure the pre-steam patch is installed
if [ ! -f "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FF7.exe" ]
then
    cp "${WINEPREFIX}/drive_c/Program Files/7th Heaven/Resources/FF7_1.02_Eng_Patch/ff7.exe" "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FF7.exe"
    cp "${WINEPREFIX}/drive_c/Program Files/7th Heaven/Resources/FF7_1.02_Eng_Patch/FF7Config.exe" "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FF7Config.exe"
fi

# Install Default 7th Heaven settings suitable for Flatpak installs
if [ ! -f "${XDG_CONFIG_HOME}/7thWorkshop/settings.xml" ]
then
    mkdir -p "${XDG_CONFIG_HOME}/7thWorkshop/"
    cp "/app/etc/7th-heaven/settings.xml" "${XDG_CONFIG_HOME}/7thWorkshop/settings.xml"
fi

if [ ! -h "${WINEPREFIX}/drive_c/Program Files/7th Heaven/7thWorkshop" ]
then
    rm -f "${WINEPREFIX}/drive_c/Program Files/7th Heaven/7thWorkshop/settings.xml"
    mkdir -p "${WINEPREFIX}/drive_c/Program Files/7th Heaven/7thWorkshop"
    ln -sfv "${XDG_CONFIG_HOME}/7thWorkshop/settings.xml" "${WINEPREFIX}/drive_c/Program Files/7th Heaven/7thWorkshop/"
fi

# Install Default FFNx settings suitable for Flatpak installs
if [ ! -f "${XDG_CONFIG_HOME}/FFNx/FFNx.toml" ]
then
    mkdir -p "${XDG_CONFIG_HOME}/FFNx/"
    cp "/app/etc/7th-heaven/FFNx.toml" "${XDG_CONFIG_HOME}/FFNx/FFNx.toml"
fi
if [ ! -h "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FFNx.toml" ]
then
    rm -f "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FFNx.toml"
    ln -sfv "${XDG_CONFIG_HOME}/FFNx/FFNx.toml" "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/"
fi

# bash 

# cd "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII"
# wine ./FF7.exe
cd "${WINEPREFIX}/drive_c/Program Files/7th Heaven"
wine "./7th Heaven.exe"