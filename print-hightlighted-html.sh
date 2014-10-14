#!/bin/sh
# Helper script for preparing long program source code for publications or
# various reports. It uses 'source-hightlight' program to do actual formatting,
# and interleaves individual code files with headers, containing file names.
# -----
# Written by Pavel Kretov in 2013.
# Licensed under the terms of WTFPL of any version.
HELP="Usage: .sh OUTFILE FILE [FILE ...]"

if [ "$#" -lt "2" ] ; then
    echo "Usage: print-hightlighted-html.sh OUTFILE FILE [INPUTFILE ...]"  2>&1
    echo "Enironment variable 'OPTIONS' is used for passing extra options" 2>&1
    echo "to 'source-hightlight' program."                                 2>&1
    exit 1
fi

OUTFILE="$1"
shift

echo "<html><body>" > "$OUTFILE"
for FILE in $@
do
    echo "<h2>$FILE</h2>" >> "$OUTFILE"
    source-highlight $OPTIONS \
        --no-doc \
        --out-format html \
        -i "$FILE" -o STDOUT >> "$OUTFILE"
done
echo "</body></html>" >> "$OUTFILE"
