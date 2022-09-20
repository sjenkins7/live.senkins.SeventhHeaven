# live.senkins.SeventhHeaven

POC attempting to wrap [7th Heaven](https://github.com/tsunamods-codes/7th-Heaven) into a Flatpak. Utilises the Steam flatpak to pull FF7.

```sh
flatpak install org.winehq.Wine/x86_64/stable-22.08
flatpak-builder --user --install --force-clean build live.senkins.SeventhHeaven.yml
flatpak run live.senkins.SeventhHeaven
```

Takes a while due to all the winetricks installs


# Caveats

* Mods unusable - This currently uses stable wine, which doesn't play well with EasyHook
  * Only known working version is Vaniglia provided by Bottles, but this is not available as a Flatpak
* winetricks aren't all silent installs
* DotNET is required as Mono doesn't display the correct CD label
* DotNET 4.8 is awkward and may fail to install for any number of reasons
* Game gets tripped up and fails to launch, because it thinks the CD is missing, despite having the full game
* Due to how 7th Heaven installs FFNx, the initial config usually gets overwritten on first setup
  * Game will crash without the correct config
* So far, only appears to reliably launch with VKD3D & DX12 configured
