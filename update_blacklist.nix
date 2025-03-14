{ pkgs, config }: let
inherit (pkgs) ipset wget;
inherit (config.services.blacklist-updater) blacklists ipSetName ipV6SetName blacklistedIPs;
in ''
# Clear ipset from previous address.
# Ignore if it fails, because we don't care 

set -e
urls=(
  ${blacklists}
)

# Output file
BLFILE="/tmp/ipblacklist.txt"
BLFILE_PROCESSED="/tmp/ipblacklist_processed.txt"

# Empty the output file if it exists
> "$BLFILE"

# Download the blacklist and add it to a file
for url in "''${urls[@]}"; do
  echo "Downloading blacklist '$url'..."
  ${wget}/bin/wget -q -O - "$url" >> "$BLFILE"
  echo >> "$BLFILE" # Add a newline separator
done

# blacklist manual ips
echo "${blacklistedIPs}">> $BLFILE

${import ./clear_blacklist.nix { inherit pkgs config; }}

echo "Updating ip:s to ${ipSetName} ip-set"
# Create an ip set and add each ip to it one by one
for IP in $(cat "$BLFILE"); do
  # Jump over ipv6 adresses
  if [[ $IP =~ ^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$ ]]; then
    echo -exist add "${ipV6SetName}" "$IP"
  else
    echo -exist add "${ipSetName}" "$IP"
  fi
done > "$BLFILE_PROCESSED"
${ipset}/bin/ipset restore < "$BLFILE_PROCESSED"
''
