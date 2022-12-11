#!/bin/bash

set -euo pipefail

STEAM_DIRECTORIES=( 
    # Steam Flatpak
    ~/.var/app/com.valvesoftware.Steam/data/Steam
    # Steam Native ( Steam Deck )
    ~/.local/share/Steam
    #!FIXME - Steam Deck SD Card?
)

detect_ff7_install() {
    for dir in "${STEAM_DIRECTORIES[@]}"
    do
        if [ -d "${dir}/steamapps/common/FINAL FANTASY VII" ]
        then
            echo "${dir}/steamapps/common/FINAL FANTASY VII"
            return
        fi
    done
}

init_wine() {

    # Don't let wine prompt for mono
    WINEDLLOVERRIDES="mscoree=d,mshtml=d" wineboot --init

    winetricks -q d3dx9
    winetricks -q msls31
    winetricks -q riched20
    winetricks -q corefonts
    winetricks -q d3dcompiler_43
    winetricks -q d3dcompiler_47

    winetricks -q vcrun2019 
    winetricks -q dotnet48
}

setup_disc() {
    # Setup Virtual Disc
    mkdir -p "${WINEPREFIX}/drive_c/FF7DISC1"
    echo "FF7DISC1" > "${WINEPREFIX}/drive_c/FF7DISC1/.windows-label"
    echo "44000000" > "${WINEPREFIX}/drive_c/FF7DISC1/.windows-serial"
    touch "${WINEPREFIX}/drive_c/FF7DISC1/FF7DISC1.TXT"
    ln -sfv "${WINEPREFIX}/drive_c/FF7DISC1" "${WINEPREFIX}/dosdevices/x:"

    wine regedit /app/etc/cd.reg
    wine64 regedit /app/etc/cd.reg
}

ensure_7h_installed() {
    # Download and install 7th Heaven into prefix
    wine /app/extra/7thHeaven-Setup.exe /VERYSILENT

    # Install Default 7th Heaven settings suitable for Flatpak installs
    if [ ! -f "${XDG_CONFIG_HOME}/7thWorkshop/settings.xml" ]
    then
        mkdir -p "${XDG_CONFIG_HOME}/7thWorkshop/"
        cp "/app/etc/settings.xml" "${XDG_CONFIG_HOME}/7thWorkshop/settings.xml"
    fi

    if [ ! -h "${WINEPREFIX}/drive_c/Program Files/7th Heaven/7thWorkshop" ]
    then
        rm -f "${WINEPREFIX}/drive_c/Program Files/7th Heaven/7thWorkshop/settings.xml"
        mkdir -p "${WINEPREFIX}/drive_c/Program Files/7th Heaven/7thWorkshop"
        ln -sfv "${XDG_CONFIG_HOME}/7thWorkshop/settings.xml" "${WINEPREFIX}/drive_c/Program Files/7th Heaven/7thWorkshop/"
    fi
}

ensure_ffnx_installed() {
    # Ensure FFNx is installed
    if [ ! -f "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FFNx.dll" ]
    then
        unzip -o /app/extra/FFNx.zip -d "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/"
        wine regedit "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FFNx.reg"
    fi

    #Install Default FFNx settings suitable for Flatpak installs
    if [ ! -f "${XDG_CONFIG_HOME}/FFNx/FFNx.toml" ]
    then
        mkdir -p "${XDG_CONFIG_HOME}/FFNx/"
        cp "/app/etc/FFNx.toml" "${XDG_CONFIG_HOME}/FFNx/FFNx.toml"
    fi
    if [ ! -h "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FFNx.toml" ]
    then
        rm -f "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FFNx.toml"
        ln -sfv "${XDG_CONFIG_HOME}/FFNx/FFNx.toml" "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/"
    fi
}

ensure_ff7_installed() {
    # Pull FF7 from Steam
    if [ ! -f "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FF7_Launcher.exe" ]
    then
        rm -rf "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/"
        mkdir -p "${WINEPREFIX}/drive_c/Games/"
        ff7_path=$(detect_ff7_install)
        if [ -z "${ff7_path}" ]
        then
            echo "Can't Detect an FF7 Install - FF7 needs to be installed manually" >&2
            exit 1
        fi
        cp -r "${ff7_path}" "${WINEPREFIX}/drive_c/Games/"
    fi
    wine regedit /app/etc/ff7.reg
}

ensure_ff7_patch_applied() {
    # Ensure the pre-steam patch is installed
    if [ ! -f "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FF7.exe" ]
    then
        cp "${WINEPREFIX}/drive_c/Program Files/7th Heaven/Resources/FF7_1.02_Eng_Patch/ff7.exe" "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/ff7.exe"
        cp "${WINEPREFIX}/drive_c/Program Files/7th Heaven/Resources/FF7_1.02_Eng_Patch/FF7Config.exe" "${WINEPREFIX}/drive_c/Games/FINAL FANTASY VII/FF7Config.exe"
    fi
}

init_wine
setup_disc

ensure_ff7_installed
ensure_7h_installed
ensure_ffnx_installed

ensure_ff7_patch_applied

cd "${WINEPREFIX}/drive_c/Program Files/7th Heaven"
wine "./7th Heaven.exe"