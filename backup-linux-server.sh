#!/usr/bin/env sh
# Simple script for backing up Linux server (running modern Debian
# distribution) using ssh, tar and openssl. The entire file system
# will be copied, compressed and encrypted (with the passphrase asked).
# ---
# Written by Pavel Kretov, Feb 2012.
# Licensed under the terms of WTFPL License of any version.
if [ $# -lt 2 ]; then
	echo "Usage: BackupLinuxServer.sh HOST FILE" 1>&2
	exit 1
fi

SERVER="$1"
TARGET="$2"
EXCLUDE="""
	--exclude=/media
	--exclude=/proc
	--exclude=/lib/init/rw
	--exclude=/sys
	--exclude=/dev
"""

echo -n "Enter encryption password: "
read PASS
if [ -z "$PASS" ]; then
	echo "Error: Password is empty." 1>&2
	exit 1
fi

export PASS
ssh "$SERVER" tar -cvpzO / $EXCLUDE | openssl aes-256-cbc -pass env:PASS > "$TARGET"
