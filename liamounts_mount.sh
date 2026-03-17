#!/bin/bash

DEVICE="$1"
REAL_MOUNTS="/realmounts"
AUTO_MOUNTS="/automounts"

if ! mountpoint -q "$REAL_MOUNTS"; then
    mount -t tmpfs tmpfs "$REAL_MOUNTS" -o mode=0700
fi

if ! mountpoint -q "$AUTO_MOUNTS"; then
    mount -t tmpfs tmpfs "$AUTO_MOUNTS" -o mode=0755
fi

direct_mount() {
    echo "direct: $1"
}

overlay_mount() {
    echo "overlay: $1"
}

for part in "$DEVICE"*; do
    [ "$part" = "$DEVICE*" ] && break
    [ -b "$part" ] || continue
    fs=$(blkid "$part" -s TYPE -o value)

    if [ -n "$fs" ]; then
        echo "Раздел $part: $fs"
        case "$fs" in
            ext*|xfs|btrfs|jfs|zfs) 
                overlay_mount "$part"
            ;;

            *)
                direct_mount "$part"
            ;;
        esac
    fi
done
