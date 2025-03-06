{
  description = "A service for updating blacklists of IPs";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    lib = nixpkgs.lib;
    blacklistModule = import ./.;
  in {
    nixosModules = rec {
      blacklist-updater = blacklistModule;
      default = blacklist-updater;
    };
  };
}
