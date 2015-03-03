#!/bin/bash
# «Every now and then my Thunderbird seems to take ages to load a message, or
# seems to get caught up initialising itself. After a bit of searching, there
# seemed to be two different issues; the global message database and possibly
# the indexes for each folder.
# Here’s the small script I wrote that will remove the global message database
# and all folder indexes.»
# ---
# Rewritten by Pavel Kretov in 2015.
# Initial code and description from:
# http://www.wordpress.lonbil.co.uk/scripts-configuration-files/rebuild-thunderbird-indexes-script/
set -o nounset
set -o errexit

if pgrep thunderbird >/dev/null ; then
    echo "There is a Thunderbird instance running" >&2
    exit 1
fi

TBDIR="$HOME/.thunderbird"
if [ ! -d "$TBDIR" ] ; then
    echo "Cannot find Thunderbird config directory." >&2
    exit 1
fi


find "$TBDIR" -name global-messages-db.sqlite -o -name \*.msf -delete

