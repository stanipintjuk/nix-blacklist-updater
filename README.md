#Blacklist Updater For NixOS

This NixOS expression will block all malicous IPs and update them daily.

The source for the malicous IPs is lists.blocklist.de

#Systemd

A systemd unit called "blacklist" will be created and will run every day at 01:00:00.

#Usage

Add this line to your imports
```
''${(import <nixpkgs> {}).fetchgit { url = "https://github.com/stanipintjuk/nix-blacklist-updater"; rev = "1.0.0"}}''
```
