pkgs:
with pkgs;
''
# Clear ipset from previous address.
# Ignore if it fails, because we don't care 

echo "Setting required variables"
IP_SET="BlackList"

set -e
BLURL="https://lists.blocklist.de/lists/all.txt"
BLFILE="/tmp/ipblacklist.txt"

# Download the blacklist and add it to a file
echo "Downloading blacklist..."
${wget}/bin/wget $BLURL -O "$BLFILE"

# Do something like this in case you want any extra blacklisted ips
#echo "
#94.234.186.42 
#94.234.34.172" >> $BLFILE

echo "Clearing $IP_SET ip-set..."
${ipset}/bin/ipset flush "$IP_SET"

echo "Updating ip:s to $IP_SET ip-set"
# Create an ip set and add each ip to it one by one
for IP in $(cat "$BLFILE"); do
  # Jump over ipv6 adresses
  if [[ $IP =~ ^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$ ]]; then
    echo "Ignoring IPv6 adress $IP"
  else 
    echo "Adding adress $IP"
    ${ipset}/bin/ipset add "$IP_SET" $IP
  fi
done

''
