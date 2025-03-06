pkgs: let
inherit (pkgs) ipset iptables;
in ''
echo "Running blacklist initializer"

IP_SET="BlackList"

# Stop if the set already exists
echo "Checking if ip-set $IP_SET already exists"
${ipset}/bin/ipset -L $IP_SET >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "$IP_SET set already exists. Exiting."
  exit 0
fi

echo "$IP_SET doesn't exist. Creating."

${ipset}/bin/ipset create "$IP_SET" hash:ip hashsize 131072

# Blacklist all addresses from this ip set
${iptables}/bin/iptables -I INPUT -m set --match-set $IP_SET src -j DROP
${iptables}/bin/iptables -I INPUT -m set --match-set $IP_SET src -j LOG --log-prefix "FW_DROPPED: "

${iptables}/bin/iptables -I FORWARD -m set --match-set $IP_SET src -j DROP
${iptables}/bin/iptables -I FORWARD -m set --match-set $IP_SET src -j LOG --log-prefix "FW_DROPPED: "

${iptables}/bin/iptables -t raw -I PREROUTING -m set --match-set $IP_SET src -j DROP
${iptables}/bin/iptables -t raw -I PREROUTING -m set --match-set $IP_SET src -j LOG --log-prefix "FW_DROPPED: "
''
