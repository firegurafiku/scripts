#!/bin/sh
# Cleanups source code files by removing trailing whitespaces from
# every line of their content.
# ---
# Written by Pavel Kretov, Jul 2014.
# Licensed under the terms of WTFPL of any version.

sed --in-place -e 's/\s\+$//' -- "$@"
