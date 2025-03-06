{ pkgs, config, ... }:
with builtins;
{
  systemd.services."blacklist" = {
    enable = config.services.blacklist-updater.enable;
    preStart = toString (pkgs.writeScript "init_blacklist.sh" (import ./init_blacklist.nix { inherit pkgs config; }));
    script = toString (pkgs.writeScript "blacklist_update.sh" (import ./update_blacklist.nix { inherit pkgs config; }));
    postStop = toString (pkgs.writeScript "clear_blacklist.sh" (import ./clear_blacklist.nix { inherit pkgs config; }));
    startAt = config.services.blacklist-updater.updateAt;
  };
}
