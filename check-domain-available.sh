#!/bin/bash
# Checks second-level domain name for availability. Originally found on:
# http://linuxconfig.org/check-domain-name-availability-with-bash-and-whois
set -o errexit
set -o nounset

function checkDomain {
    fqdn="$1"
    whois "$fqdn" |
    egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri' &&
    echo "$fqdn: available" || echo "$fqdn: not available" 
}

if [ "$#" == "0" ]; then
    echo "You need to supply at least one argument!"
    exit 1
fi

DOMAINS="
    .com .co.uk .net .info .mobi .org
    .tv .cc .eu .ru .su .in .it .sk .com.au"
 
for N in $@ ; do
    if [[ "$N" = *. ]] ; then
        checkDomain "${N%%.}"
    else
        for D in $DOMAINS ; do
            checkDomain "$N$D"
        done
    fi
done 

