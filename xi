#!/bin/sh
# /usr/bin/xi: simple script for .xinitrc file selection.
# It considers files in ~/.xinitrcs directory as profiles and runs
# default X server with specified profile.
#
# E.g. running:
#
#   $ xi fluxbox
#
# means that ~/.xinitrcs/fluxbox will be used as .xinitrc for
# starting X server.
# --
# Written by Firegurafiku, Oct 2012.
# Licensed under the terms of WTFPL of any version.

PROFILE="${1:-default}"
CONFIG="$HOME/.xinitrcs/$PROFILE"

# Firstly we should check if there exists
# file with configuration
if [ ! -f "$CONFIG" ]
then
    echo "Unable to find config file $CONFIG"
else
    # Use the force! XINITRC environment variable allows
    # us not to create symbolic links anymore.
    # -- it was:
    # ln -s -f "${CONFIG}" "${HOME}/.xinitrc"
    XINITRC="$CONFIG" xinit 2>&1 >/dev/null
fi

