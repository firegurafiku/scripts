#!/bin/sh
set -o errexit
set -o nounset

getRepositoryType() {
    [ -d "$1/.svn"   ] && echo "svn"   && return
    [ -d "$1/.git"   ] && echo "git"   && return
    [ -d "$1/.hg"    ] && echo "hg"    && return
    [ -d "$1/_darcs" ] && echo "darcs" && return
    return 1
}

getRepositoryStatus_svn() {
    [ `svn status "$1" | wc -l` -eq 0 ] \
        && echo "clean" || echo "dirty"
}

getRepositoryStatus_git() {
    echo "unknown"
}

getRepositoryStatus_hg() {
    echo "unknown"
}

getRepositoryStatus_darcs() {
    echo "unknown"
}

# --- main ---

if [ "$#" -ne 1 ] ; then
    echo "Error: exactly one argument must be given." 1>&2
    exit 1
fi

ROOT="$1"

find "$ROOT" \
    -exec [ -d {}/.svn -o -d {}/.git -o -d {}/.hg -o -d {}/_darcs ] \;\
    -print -prune | while read DIR
do
    TYPE=`getRepositoryType "$DIR"`
    STAT=`getRepositoryStatus_${TYPE} "$DIR"`
    printf "%-10s %-10s %s" "$TYPE" "$STAT" "$DIR"
    echo
done

