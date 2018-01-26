#!/bin/bash
# Checks second-level domain name for availability. Originally found on:
# http://linuxconfig.org/check-domain-name-availability-with-bash-and-whois
set -o errexit
set -o nounset

function checkDomain {
    local fqdn="$1"
    whois "$fqdn" |
    egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri' &&
    echo "$fqdn: available" || echo "$fqdn: not available" 
}

if [ "$#" == "0" ]; then
    echo "You need to supply at least one argument!" 2>&1
    exit 1
fi

declare -ar suffixes=(
    .com .co.uk .net .info .mobi .org .io
    .tv .cc .eu .ru .su .in .it .sk .com.au)

declare name
declare suffix
for name in "$@" ; do
    if [[ "$name" = *. ]]; then
        checkDomain "${name%%.}"
    else
        for suffix in "${suffixes[@]}"; do
            checkDomain "$name$suffix"
        done
    fi
done 
