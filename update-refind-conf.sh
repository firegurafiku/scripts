#!/bin/bash
# This script scans /boot directory and Generates configuration file for
# rEFInd bootloader which is often used on Mac computers running Linux.
# Generally speaking, the script to operate
# properly requires a Linux system:
#  - with rEFInd bootloader installed on a separate HFS+ partition
#    labeled "refind" (adjustable with $REFIND_LABEL variable); 
#  - with /boot directory ($BOOT_DIR) on a separate partition
#    labeled "/boot" ($BOOT_LABEL);
#  - with root filesystem labeled "/" ($ROOT_LABEL).
# Please, carefully read the script source code before trying to use it
# or things will get dangerous. You MUST understand what you're doing and how
# rEFInd works before giving this script a sudo.
# Read http://www.rodsbooks.com/refind/ for more information about rEFInd.
# The specific section http://www.rodsbooks.com/refind/configfile.html#stanzas
# is devoted to target file format this script generates.
# Also note that script uses some bashisms so do not change the shebang line.
# ---
# Written by Pavel Kretov in 2014.
# Licensed under the terms of WTFPL of any version.
set -o errexit
set -o nounset

# Please, adjust these settings according to your system.
BOOT_DIR="/boot"
BOOT_LABEL="/boot"
ROOT_LABEL="/"
REFIND_LABEL="refind"
REFIND_CONFIG="/EFI/refind/stanzas.conf"
ENTRY_NAME="Fedora Linux"
ENTRY_ICON="EFI/refind/icons/os_fedora.png"
APPEND=""

# We need root privileges to mount and unmount partitions.
if [[ $(id -u) != 0 ]] ; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Unmounts HFS+ partition with rEFInd and removes any temporary files.
cleanup() {
    umount "$MOUNTPOINT"
    rmdir "$MOUNTPOINT"
    rm "$TEMP"
}

trap cleanup 0

# Create temporary file to write configuration to. It will be used as
# itermediate storage in order not to damage existing configuration if
# something goes wrong. Also it is used as a destination to diff against
# for user to know the changes they confirm.
TEMP=`mktemp`

# Mount blessed HFS+ partition at a temporary mount point.
MOUNTPOINT=`mktemp --directory`
mount -t hfsplus "LABEL=$REFIND_LABEL" "$MOUNTPOINT"

# Detect GPT GUIDs for /boot and / partitions.
BOOT=$(blkid -t LABEL="$BOOT_LABEL" -s PARTUUID -o value)
ROOT=$(blkid -t LABEL="$ROOT_LABEL" -s PARTUUID -o value)

# Now start building new configuration file. First or all we have to enumerate
# all kernels and initrds (found as vmlinuz-* initramfs-*.img with exact
# version part of file name). Second, sort kernels most recent first. Then
# generate submenu entry for each of that kernels, even for resque one.
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

    # Get initrd file matching the kernel.
    INITRD="${KERNEL/vmlinuz/initramfs}.img"
    if [ ! -f "$BOOT_DIR/$INITRD" ] ; then
        echo "Initrd '$INITRD' does not exist." 1>&2
        exit 1
    fi

    # First kernel (most resent) counts as the default one.
    if [[ "$FIRST" == "yes" ]] ; then
        echo "    icon $ENTRY_ICON"
        echo "    volume $BOOT"
        echo "    loader $KERNEL"
        echo "    initrd $INITRD"
        echo "    options \"ro root=PARTUUID=$ROOT $APPEND\"" 
        echo
        FIRST="no"
    fi

    # If kernel version is 0 it counts as a resque system and boots without
    # any root filesystem attached.
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

# Now new configuration file is successfully generated. If it is equal to
# already existing one, no futher action needed.
OLD="$MOUNTPOINT/$REFIND_CONFIG"
NEW="$TEMP"
if cmp "$OLD" "$NEW" ; then
    echo "Configuration already updated."
    exit
fi

# It there are changes, show them to user as a unified diff. After that, ask
# if they feel the changes are nice and could be applied.
diff -u "$OLD" "$NEW" | less
echo -n "Was this diff okay? Owerwrite target configuration file (y/N): "
read CONFIRM

if [[ "$CONFIRM" != "y" ]] ; then
    echo "No configuration written. Exiting."
else
    cp "$NEW" "$OLD"
    echo "Configuration successfully updated."
fi
