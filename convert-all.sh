#!/bin/sh
# Convenience script on top of ImageMagick convert tool which allows you
# to convert several files with single command.
# ---
# Written by Firegurafiku, Jul 2012.
# Licensed under the terms of WTFPL of any version.

if [ $# -lt 3 ]
then
    echo "Not enough actual parameters."
    echo "Usage:"
    echo "    convert-all.sh TARGET_FORMAT FILE [FILE ... ]"
    exit
fi

TARGET_FORMAT="$1"
shift

for FILE in $@
do
    NOEXT=`echo "$FILE" | sed 's/\(.*\.\)[^.]*/\1/'`
    convert "$FILE" "$NOEXT$TARGET_FORMAT"
done

