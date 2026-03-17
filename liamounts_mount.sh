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

raw_mount() {
    mkdir -p -m 0000 "$2"
    mount -o nosuid,nodev,uid=0,gid=0,umask=000 "$1" "$2"
}

direct_mount() {
    
}

overlay_mount() {
    
}

for part in "$DEVICE"*; do
    [ "$part" = "$DEVICE*" ] && break
    [ -b "$part" ] || continue
    fs=$(blkid "$part" -s TYPE -o value)

    if [ -n "$fs" ]; then
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
