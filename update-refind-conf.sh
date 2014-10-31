#!/bin/bash
set -o errexit
set -o nounset

BOOT_DIR="/boot"
BOOT_LABEL="/boot"
ROOT_LABEL="/"
REFIND_LABEL="refind"
REFIND_CONFIG="/EFI/refind/stanzas.conf"
ENTRY_NAME="Fedora Linux"
ENTRY_ICON="EFI/refind/icons/os_fedora.png"
APPEND=""

if [[ $(id -u) != 0 ]] ; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

cleanup() {
    umount "$MOUNTPOINT"
    rmdir "$MOUNTPOINT"
    rm "$TEMP"
}

trap cleanup 0

TEMP=`mktemp`
MOUNTPOINT=`mktemp --directory`
mount -t hfsplus "LABEL=$REFIND_LABEL" "$MOUNTPOINT"

BOOT=$(blkid -t LABEL="$BOOT_LABEL" -s PARTUUID -o value)
ROOT=$(blkid -t LABEL="$ROOT_LABEL" -s PARTUUID -o value)


{ :
echo "# Automatically generated configuration file"
echo "# Do NOT edit manually. Edit refind.conf instead."
echo "menuentry \"$ENTRY_NAME\" {"

FIRST="yes"
find "$BOOT_DIR" -maxdepth 1 -name vmlinuz-\* | sort -r | while read KERNEL ; do
    KERNEL=`basename "$KERNEL"`
    if [[ "$KERNEL" =~ [0-9.]+ ]] ; then
        VERSION="$BASH_REMATCH"
    else
        echo "File '$KERNEL' must contain version number in name." 1>&2
        exit 1
    fi

    INITRD="${KERNEL/vmlinuz/initramfs}.img"
    if [ ! -f "$BOOT_DIR/$INITRD" ] ; then
        echo "Initrd '$INITRD' does not exist." 1>&2
        exit 1
    fi

    if [[ "$FIRST" == "yes" ]] ; then
        echo "    icon $ENTRY_ICON"
        echo "    volume $BOOT"
        echo "    loader $KERNEL"
        echo "    initrd $INITRD"
        echo "    options \"ro root=PARTUUID=$ROOT $APPEND\"" 
        echo
        FIRST="no"
    fi

    if [[ "$VERSION" == 0 ]] ; then
        echo "    submenuentry \"Resque system boot\" {"
        echo "        loader $KERNEL"
        echo "        initrd $INITRD"
        echo "    }"
        echo
    else
        echo "    submenuentry \"Normal boot with kernel $VERSION\" {"
        echo "        loader $KERNEL"
        echo "        initrd $INITRD"
        echo "        options \"ro root=PARTUUID=$ROOT $APPEND\""
        echo "    }"
        echo
    fi
done

echo "}"
} >"$TEMP"

if [[ "$FIRST" == "yes" ]] ; then
    echo "No kernels were found. Is '$BOOT_DIR' mounted?" 1>&2
    exit 1
fi

OLD="$MOUNTPOINT/$REFIND_CONFIG"
NEW="$TEMP"
if cmp "$OLD" "$NEW" ; then
    echo "Configuration already updated."
    exit
fi

diff -u "$OLD" "$NEW" | less
echo -n "Was this diff okay? Owerwrite target configuration file (y/N): "
read CONFIRM

if [[ "$CONFIRM" != "y" ]] ; then
    echo "No configuration written. Exiting."
else
    cp "$NEW" "$OLD"
    echo "Configuration successfully updated."
fi

