# Blacklist Updater For NixOS

This NixOS expression will block all malicous IPs and update them daily.

The source for the malicious IPs is lists.blocklist.de

# Systemd

A systemd unit called "blacklist" will be created and will run every day at 01:00:00.

# Usage

1. Add this to your flake inputs:
```
blacklist-updater = {
  url = "github:stanipintjuk/nix-blacklist-updater";
  inputs.nixpkgs.follows = "nixpkgs";
};
```
2. add `blacklist-updater.nixosModules.blacklist-updater` to your modules
3. set `services.blacklist-updater.enable = true;`
4. run ```nixos-rebuild switch``` and let NixOS do the rest :)
