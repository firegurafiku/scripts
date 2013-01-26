#!/bin/bash
HELP_MSG='''
Prints out most frequently used commands from history. The number
of positions can be given as command line argument, by default
it is 10.

Usage:
  $ history | history-top10 100

Note that script acts as a pipeline filter, not as a standalone
executable.
--
Written by Firegurafiku, Aug 2012.
License terms are unclear since script contains some code taken from
the Internet. Anyway, I think you can do anything the fuck you want
to with this code.
'''

if [ "$1" == "--help" ]
then
    echo "$HELP_MSG"
    exit
fi

LINES=${1:-10}
sed -ne 's/^\s*[0-9][0-9]*\s\s*\(\S\S*\).*$/\1/p' \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -n "$LINES"

