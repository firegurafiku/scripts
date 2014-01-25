#!/bin/sh
set -o nounset
set -o errexit

function errorExit() {
    kdialog \
        --title "Truecrypt + BackInTime launcher" \
	--error "$@"
    exit 1
}


[ "$#" -eq "2" ] || errorExit \
    "Not enought command line arguments given." \
    "Arguments: DEVICE PROFILE MOUNTPOINT"

DEVICE="$1"
MOUNTPOINT="$2"

[ -b "$DEVICE" ] || errorExit \
    "Cannot find backup drive connected to this computer." \
    "Please check if it is plugged in and accessible." \
    "Device path is '$DEVICE'."

[ -d "$MOUNTPOINT" ] || errorExit \
    "Mount point directory '$MOUNTPOINT' does not exist." \
    "Please create it manually."

truecrypt --mount "$DEVICE" "$MOUNTPOINT"
trap "truecrypt --dismount '$MOUNTPOINT'" 0

backintime-kde4

