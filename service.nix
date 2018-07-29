{ pkgs, ... }:
with builtins;
{
  systemd.services."blacklist" = {
    enable = true;
    preStart = toString (pkgs.writeScript "init_blacklist.sh" (import ./init_blacklist.nix pkgs));
    script = toString (pkgs.writeScript "blacklist_update.sh" (import ./update_blacklist.nix pkgs));
    startAt = "*-*-* 01:00:00";
  };
}
