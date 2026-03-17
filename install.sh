#!/bin/bash

umount_all() {
    local dir="$1"
    
    for d in "$dir"/*/; do
        [ -d "$d" ] || continue
        
        umount "$d"
        rmdir "$d"
    done
}

umount_all /realmounts
umount /realmounts
rmdir /realmounts
mkdir -p /realmounts
chmod 0700 /realmounts

umount_all /automounts
umount /automounts
rmdir /automounts
mkdir -p /automounts
chmod 0755 /automounts

cp 99-liamounts.rules /etc/udev/rules.d/99-liamounts.rules
cp liamounts_mount_wrapper.sh /usr/bin/liamounts_mount_wrapper.sh
cp liamounts_mount.sh /usr/bin/liamounts_mount.sh
