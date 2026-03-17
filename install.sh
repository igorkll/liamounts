#!/bin/bash

if command -v apt &> /dev/null; then
    apt install -y at
    apt install -y bindfs
fi

grep -q '^user_allow_other' /etc/fuse.conf || echo 'user_allow_other' >> /etc/fuse.conf

if command -v systemctl &> /dev/null; then
    systemctl mask udisks2.service
    systemctl stop udisks2.service
fi

nuke_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        return
    fi
    
    echo "nuke directory: $dir"
    
    # 1. Принудительно размонтировать всё внутри
    mount | grep "$dir" | awk '{print $3}' | sort -r | while read -r mp; do
        echo "  umount internal: $mp"
        umount -l "$mp" 2>/dev/null
    done
    
    # 2. Размонтировать саму директорию (если это точка монтирования)
    if mountpoint -q "$dir"; then
        echo "  umount base: $dir"
        umount -l "$dir" 2>/dev/null
    fi
    
    # 3. Удалить всё рекурсивно (принудительно)
    echo "  delete internal: $dir"
    rm -rf "${dir:?}"/* 2>/dev/null
    
    # 4. Удалить саму директорию
    echo "  delete base: $dir"
    rm -rf "$dir" 2>/dev/null
}

nuke_directory "/realmounts"
nuke_directory "/automounts"

mkdir -p /realmounts
chmod 0700 /realmounts

mkdir -p /automounts
chmod 0755 /automounts

cp 99-liamounts.rules /etc/udev/rules.d/99-liamounts.rules
cp liamounts_mount_wrapper.sh /usr/bin/liamounts_mount_wrapper.sh
cp liamounts_mount.sh /usr/bin/liamounts_mount.sh
cp liamounts_umount_wrapper.sh /usr/bin/liamounts_umount_wrapper.sh
cp liamounts_umount.sh /usr/bin/liamounts_umount.sh
