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
    cd "$1"
    [ `svn status | wc -l` -eq 0 ] && echo "-" || echo "*"
}

#
# @see http://stackoverflow.com/a/3338774/1447225
# @see http://stackoverflow.com/a/3921928/1447225
getRepositoryStatus_git() {
    cd "$1"
    RES=""

    [ `git log --format=oneline --branches --not --remotes | wc -l` -ne 0 ] \
       && RES="p${RES}"

    [ `git stash show 2>/dev/null | wc -l` -ne 0 ] \
        && RES="s${RES}"

    [ -d ".git/rebase-merge" -o -d ".git/rebase-apply" ] \
        && RES="b${RES}"

    [ `git status --porcelain | wc -l` -ne 0 ] \
        && RES="*${RES}"

    [ ! -z "$RES" ] && echo "$RES" || echo "-"
}

getRepositoryStatus_hg() {
    echo "?"
}

getRepositoryStatus_darcs() {
    echo "?"
}

# --- main ---

if [ \( $# -eq 2 \) -a \( ":$1" = ":--dirty" -o ":$1" = ":--all" \) -a -d "$2" ]
then :
else
    echo "Usage: $0 (--all|--dirty) PROJECTS_ROOT" 2>&1
    exit 1
fi

MODE="$1"
ROOT="$2"

find "$ROOT" \
    -exec [ -d {}/.svn -o -d {}/.git -o -d {}/.hg -o -d {}/_darcs ] \;\
    -print -prune | while read DIR
do
    TYPE=`getRepositoryType "$DIR"`
    STAT=`getRepositoryStatus_${TYPE} "$DIR"`

    [ ":$MODE" = ":--dirty" -a ":$STAT" = ":-" ] &&
        continue

    printf "%-5s %-5s %s" "$TYPE" "$STAT" "$DIR"
    echo
done
