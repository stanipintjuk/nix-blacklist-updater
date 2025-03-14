{ pkgs, config, lib, ... }:
with builtins;
let cfg = config.services.blacklist-updater;
in {
  systemd.services."blacklist" = {
    enable = cfg.enable;
    preStart = toString (pkgs.writeScript "init_blacklist.sh" (import ./init_blacklist.nix { inherit pkgs config; }));
    script = toString (pkgs.writeScript "blacklist_update.sh" (import ./update_blacklist.nix { inherit pkgs config; }));
    postStop = toString (pkgs.writeScript "clear_blacklist.sh" (import ./clear_blacklist.nix { inherit pkgs config; }));
    startAt = cfg.updateAt;

    wantedBy = [ "multi-user.target" ]; # start at boot
    after = [ "network.target" ]; # Ensure networking is up
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
  };
}
