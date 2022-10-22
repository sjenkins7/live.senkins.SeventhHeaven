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
* It takes a moment to load on the Steam Deck - you will see a black screen for some time
* Quitting the game often causes it to lock up - use `flatpak kill` to force close the game
* 7th Heaven appears to be overriding the FFNx config provided

# TODO

* Write a wrapper that better handles winetricks silently
* Find a way to resolve the crash on boot with mods
* Find the issue causing Mono to fail to detect the disc & raise upstream
* Remove wine file associations
* Map Steam Deck controls