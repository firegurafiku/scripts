#!/bin/sh
# Prepends modification date to given filenames. For example, is there is
# a file "HotTeensXXX.avi" with modification date set to Jan 8, 2002, then
# the resulting filename will be "2002-01-08 HotTeensXXX.avi". Such names
# are useful sometimes for photo and video collections.
# ---
# Written by Firegurafiku, Jul 2012.
# Licensed under the terms of WTFPL of any version.

for FILENAME in "$@"
do
    TIMESTAMP=`date --reference="$FILENAME" +%F`
    DIRNAME=`dirname -- "$FILENAME"`
    BASENAME=`basename -- "$FILENAME"`
    mv -i -- "$FILENAME" "$DIRNAME/$TIMESTAMP $BASENAME"
done

