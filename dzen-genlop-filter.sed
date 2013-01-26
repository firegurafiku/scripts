#!/bin/sed -nf
# Simple sed script for filtering the output of genlop program for use
# with dzen2 statusbar. Tested on genlop-0.30.8 on Feb 2, 2012.
# --
# Written by Firegurafiku, Aug 2012.
# Licensed under the terms of WTFPL of any version.
#
/^[^0-9]*\([0-9]\+\) out of \([0-9]\+\)/ {
    s//[\1\/\2] /;
    H
};
/^\s*\*\s*\(\S\+\)/ {
    s//\1/;
    H
}; 
${
    g;
    s/\n//g;
    p
}

