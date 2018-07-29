pkgs:
with pkgs;
''
# Clear ipset from previous address.
# Ignore if it fails, because we don't care 

IP_SET="BlackList"

set -e
BLURL="https://lists.blocklist.de/lists/all.txt"
BLFILE="/tmp/ipblacklist.txt"
# Download the blacklist and add it to a file
${wget}/bin/wget $BLURL -O "$BLFILE"

# Do something like this in case you want any extra blacklisted ips
#echo "
#94.234.186.42 
#94.234.34.172" >> $BLFILE

${ipset}/bin/ipset flush "$IP_SET"
# Create an ip set and add each ip to it one by one
for IP in $(cat "$BLFILE"); do
  ${ipset}/bin/ipset add "$IP_SET" $IP
done

''
