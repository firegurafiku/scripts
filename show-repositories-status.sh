#!/bin/sh
# Recursively searches for repositories, checks them for local modifications
# and prints their status in abbreviated form. SVN and Git are currently
# supported, while Mercurial and Darcs are just stubs. Abbreviations are the
# following:
#   "-" repository is clean
#   "*" uncommitted changes
#   "s" stashed changes (for Git only)
#   "p" unpushed commits (for Git only)
#   "b" bisect is in progress (for Git only)
#   "r" rebase is in progress (for Git only)
#   "?" unknown or unsupported state
# See project's wiki on Bitbucket for more information
# ---
# Copyright (c) Pavel Kretov, Jul 2012.
# Licensed under the terms of WTFPL of any version.
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

    [ -f ".git/BISECT_START" ] \
        && RES="b${RES}"

    [ -d ".git/rebase-merge" -o -d ".git/rebase-apply" ] \
        && RES="r${RES}"

    [ `git status --porcelain --ignore-submodules | wc -l` -ne 0 ] \
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
USAGE="
Usage: $0 [-adtHh?] [--] DIR [DIR ...]
Arguments are directories to find repositories in. Options must precede
arguments and stand for the following:
  -a (\"all\")   -- ontput statuses for all repositories (default)
  -d (\"dirty\") -- output statuses only for unclean repositories
  -t (\"text\")  -- output in plain text (default)
  -H (\"HTML\")  -- output in HTML format"

MODE="all"
FORMAT="text"
while getopts 'adtHh' OPT; do
    case "$OPT" in
        a) MODE="all" ;;
        d) MODE="dirty" ;;
        t) FORMAT="text" ;;
        H) FORMAT="html" ;;
        h|\?)
           echo "$USAGE" >&2
           exit 1
           ;;
    esac
done

shift `expr $OPTIND - 1`
if [ "$#" -lt 1 ] ; then
    echo "$USAGE" >&2
    exit 1
fi

[ "$FORMAT" = "html" ] && echo "<table>"
find "$@" \
    -exec [ -d {}/.svn -o -d {}/.git -o -d {}/.hg -o -d {}/_darcs ] \;\
    -print -prune | sort | while read DIR
do
    TYPE=`getRepositoryType "$DIR"`
    STAT=`getRepositoryStatus_${TYPE} "$DIR"`

    [ "$MODE" = "dirty" -a ":$STAT" = ":-" ] &&
        continue

    if [ "$FORMAT" = "html" ] ; then
        case "$STAT" in
            "-") ATTRS="bgcolor='pale green'" ;;
            "p") ATTRS="bgcolor='light blue'" ;;
              *) ATTRS="bgcolor='pink'" ;;
        esac
        printf "<tr><td>%s&nbsp;</td><td %s>&nbsp;%s&nbsp;</td><td>&nbsp;%s</td></tr>" \
            "$TYPE" "$ATTRS" "$STAT" "$DIR"
        echo
    else
        printf "%-5s %-5s %s" "$TYPE" "$STAT" "$DIR"
        echo
    fi
done
[ "$FORMAT" = "html" ] && echo "</table>"

