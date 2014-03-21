#!/bin/sh
# Helper script for staging files to Git ignoring their contents. It is useful
# because Git GUI doesn't allow to stage only part of newly created file.
# ---
# Copyright (c) 2014, Pavel Kretov <firegurafiku@gmail.com>
# Licensed under the terms of WTFPL of any version.
set -o nounset
set -o errexit
for FILE in "$@" ; do
   TMP=`mktemp`
   mv "$FILE" "$TMP"
   touch "$FILE"
   git add "$FILE"
   mv -f "$TMP" "$FILE"
done

