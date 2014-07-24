#!/bin/bash
# Checks second-level domain name for availability. Originally found on:
# http://linuxconfig.org/check-domain-name-availability-with-bash-and-whois
set -o errexit
set -o nounset

if [ "$#" == "0" ]; then
    echo "You need tu supply at least one argument!"
    exit 1
fi

DOMAINS="
    .com .co.uk .net .info .mobi .org .tel .biz
    .tv .cc .eu .ru .su .in .it .sk .com.au"
 
for N in $@ ; do 
    for D in $DOMAINS ; do
        whois "$N$D" |
        egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri' &&
        echo "$N$D: available" 
    done
done 

