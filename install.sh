#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Restart with root..."
    exec sudo "$0" "$@"
    exit $?
fi

# ---------------- install packages

if command -v apt &> /dev/null; then
    apt install -y at
    apt install -y bindfs
fi

# ---------------- enable user_allow_other

grep -q '^user_allow_other' /etc/fuse.conf || echo 'user_allow_other' >> /etc/fuse.conf

# ---------------- build liamountsctl

cd liamountsctl
./build.sh
cd ..

# ---------------- install liamountsctl

cp liamountsctl/liamountsctl /usr/bin/liamountsctl
chown root:root /usr/bin/liamountsctl
chmod 4755 /usr/bin/liamountsctl # liamountsctl is SUID

# ---------------- disable udisks2

if command -v systemctl &> /dev/null; then
    systemctl mask udisks2.service
    systemctl stop udisks2.service
fi

# ---------------- remove directories

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

# ---------------- create directories

mkdir -p /realmounts
chmod 0700 /realmounts

mkdir -p /automounts
chmod 0755 /automounts

# ---------------- copy files

cp 99-liamounts.rules /etc/udev/rules.d/99-liamounts.rules
chmod 644 /etc/udev/rules.d/99-liamounts.rules
chown root:root /etc/udev/rules.d/99-liamounts.rules

for script in liamounts_mount_wrapper.sh liamounts_mount.sh liamounts_umount_wrapper.sh liamounts_umount.sh; do
    cp "$script" "/usr/bin/$script"
    chmod 755 "/usr/bin/$script"
    chown root:root "/usr/bin/$script"
done

# ---------------- update disks

try_mount() {
    local dev="$1"
    [ -b "$dev" ] || return
    
    if udevadm info --query=property "$dev" 2>/dev/null | grep -q "ID_FS_USAGE=filesystem"; then
        echo "try mount device: $dev"
        /usr/bin/liamounts_mount_wrapper.sh "$dev"
    fi
}

# SATA/SAS/NVMe
for dev in /dev/sd* /dev/hd* /dev/nvme* /dev/vd*; do
    try_mount "$dev"
done

# MMC/SD-карты
for dev in /dev/mmcblk*; do
    try_mount "$dev"
done

# CD/DVD-ROM
for dev in /dev/sr*; do
    try_mount "$dev"
done

# MD RAID
for dev in /dev/md*; do
    try_mount "$dev"
done

