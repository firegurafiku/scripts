#!/bin/sh

# Usage: highlight-code-files.sh OUTFILE FILE [FILE ...]

OUTFILE="$1"
shift

{ : ;
echo "<html><body>"
for FILE in $@
do
    echo "<h2>$FILE</h2>"
    highlight $OPTIONS --no-doc --fragment --enclose-pre --inline-css --style=print -i "$FILE"
done
echo "</body></html>" ; } >"$OUTFILE"

