#!/bin/sh
# This script looks for doxyfiles and run doxygen on them to regenerate
# documentation. Useful for calling from IDE as an external tool.
# Command line syntax:
#
#   $ ide-run-doxygen [-q] [-v] [-d DOXYFILE] [DIRECTORY]
#
# where DOXYFILE is a pattern for find -name and DIRECTORY specifies
# a directory to start search from.
# --
# Written by Firegurafiku, Jan 2012.
# Licensed under the terms of WTFPL of any version.

DOXYFILE="Doxyfile"
DOXYCONF=""
while getopts "qvd:" FLAG
do
    case "$FLAG" in
        q) DOXYCONF="QUIET = YES";;
        v) DOXYCONF="QUIET = NO";;
        d) DOXYFILE="$OPTARG";;
    esac
done

shift `expr $OPTIND - 1`

DIRECTORY="."
[ ! -z "$1" ] && DIRECTORY="$1"

find "$DIRECTORY" -name "$DOXYFILE" -print | while read FILENAME 
do
    DOXYDIR=`dirname "$FILENAME"`
    echo "*********************************************************************"
    echo " Running doxygen on file '$FILENAME' with '$DOXYCONF'"
    echo "*********************************************************************"
    ( cat "$FILENAME" && echo "$DOXYCONF" ) | (cd $DOXYDIR && doxygen - )
done

