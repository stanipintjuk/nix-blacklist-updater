{ pkgs, config, lib, ... }:
with builtins;
let cfg = config.services.blacklist-updater;
in {
  systemd.services."blacklist" = {
    enable = cfg.enable;
    preStart = toString (pkgs.writeScript "init_blacklist.sh" (import ./init_blacklist.nix { inherit pkgs config; }));
    script = toString (pkgs.writeScript "blacklist_update.sh" (import ./update_blacklist.nix { inherit pkgs config; }));
    postStop = lib.optionalString (!cfg.runInitially) (toString (pkgs.writeScript "clear_blacklist.sh" (import ./clear_blacklist.nix { inherit pkgs config; })));
    startAt = cfg.updateAt;

    wantedBy = lib.optionals cfg.runInitially [ "multi-user.target" ]; # start at boot
    after = lib.optionals cfg.runInitially [ "network.target" ]; # Ensure networking is up
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
  };
}
