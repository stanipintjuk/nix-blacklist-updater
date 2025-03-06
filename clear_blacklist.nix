{ pkgs, config }: let
inherit (pkgs) ipset wget;
inherit (config.services.blacklist-updater) ipSetName;
in ''
echo "Clearing ${ipSetName} ip-set..."
${ipset}/bin/ipset flush "${ipSetName}"
''
