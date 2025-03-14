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

# IPv4 and IPv6 regex patterns with CIDR notation support - WARNING: might not be correct for all IPs (e.g. ignore valid ones or accept wrong ones), but seems to work fine
ipv4_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}(\/[0-9]{1,2})?$"
ipv6_regex="^([0-9a-fA-F:]+::?[0-9a-fA-F]*)+(\/[0-9]{1,3})?$"

# Use a temporary buffer to improve performance
{
    while IFS= read -r IP; do
        if [[ $IP =~ $ipv4_regex ]]; then
            echo -exist add "${ipSetName}" "$IP"
        elif [[ $IP =~ $ipv6_regex ]]; then
            echo -exist add "${ipV6SetName}" "$IP"
        else
            echo "Warning: Invalid line skipped -> $IP" >&2
        fi
    done < "$BLFILE"
} > "$BLFILE_PROCESSED"
${ipset}/bin/ipset restore < "$BLFILE_PROCESSED"
''
