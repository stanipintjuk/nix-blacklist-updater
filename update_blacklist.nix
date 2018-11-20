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
  ${ipset}/bin/ipset add "$IP_SET" $IP
done

''
