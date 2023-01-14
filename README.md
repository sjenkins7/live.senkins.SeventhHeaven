# live.senkins.SeventhHeaven

POC attempting to wrap [7th Heaven](https://github.com/tsunamods-codes/7th-Heaven) into a Flatpak. Utilises the Steam flatpak to pull FF7.

```sh
flatpak install org.winehq.Wine/x86_64/stable-22.08
flatpak-builder --user --install --force-clean build live.senkins.SeventhHeaven.yml
flatpak run live.senkins.SeventhHeaven
```

Takes a while due to all the winetricks installs


# Caveats

* Currently doesn't launch unless you override the installed Wine version with Proton 7.0
* It takes a moment to load on the Steam Deck - you will see a black screen for some time
* Quitting the game often causes it to lock up - use `flatpak kill` to force close the game
* This uses the Canary version currently - Canary links get replaced often, so you will have to update the manifest

# TODO

* Write a wrapper that better handles winetricks silently
* Find the issue causing Mono to fail to detect the disc & raise upstream
* Remove wine file associations
* Map Steam Deck controls
* Add installs for VC runtime ( Installer does this currently and isn't quiet about it )