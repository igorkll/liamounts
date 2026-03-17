#!/bin/bash

exec >> /var/log/liamounts.log 2>&1

PART="$1"
echo "liamounts mount: $PART"

REAL_MOUNTS="/realmounts"
AUTO_MOUNTS="/automounts"

if ! mountpoint -q "$REAL_MOUNTS"; then
    mount -t tmpfs tmpfs "$REAL_MOUNTS" -o nosuid,nodev,mode=0700
fi

if ! mountpoint -q "$AUTO_MOUNTS"; then
    mount -t tmpfs tmpfs "$AUTO_MOUNTS" -o nosuid,nodev,mode=0755
fi

get_fs_name() {
    local device="$1"
    local name
    
    # Пытаемся получить LABEL
    name=$(blkid -s LABEL -o value "$device" 2>/dev/null)
    
    # Если нет LABEL, пробуем UUID
    if [ -z "$name" ]; then
        name=$(blkid -s UUID -o value "$device" 2>/dev/null)
    fi
    
    # Если и UUID нет, используем имя устройства (sdb1)
    if [ -z "$name" ]; then
        name=$(basename "$device")
    fi
    
    # Очищаем имя: только буквы, цифры, _, -, .
    # Все остальное заменяем на _
    name=$(echo "$name" | sed 's/[^a-zA-Z0-9_.-]/_/g')
    
    # Убираем лишние подчеркивания подряд
    name=$(echo "$name" | sed 's/__*/_/g')
    
    # Убираем . в начале (скрытые директории)
    name=$(echo "$name" | sed 's/^\./_/')
    
    # Ограничиваем длину (макс 255 для ФС, берем 128 для запаса)
    name=$(echo "$name" | cut -c1-128)
    
    echo "$name"
}

direct_mount() {
    local name="$(get_fs_name "$1")"
    local path="${AUTO_MOUNTS}/$name"

    echo "direct mount: \"$name\" to \"$path\""
    
    mkdir -p -m 0000 "$path"
    mount -o nosuid,nodev,uid=0,gid=0,umask=000 "$1" "$path"
}

overlay_mount() {
    local name="$(get_fs_name "$1")"
    local path="${REAL_MOUNTS}/$name"
    local bind="${AUTO_MOUNTS}/$name"

    echo "overlay mount: \"$name\" to \"$path\" bind \"$bind\""

    mkdir -p -m 0000 "$path"
    mount -o nosuid,nodev "$1" "$path"

    mkdir -p -m 0000 "$bind"
    bindfs --force-user=root --force-group=root --perms=0777 --chown-ignore --chgrp-ignore --chmod-ignore -o nosuid,nodev,allow_other "$path" "$bind"
}

fs=$(blkid "$PART" -s TYPE -o value)
echo "fs type: $fs"
if [ -n "$fs" ]; then
    case "$fs" in
        ext*|xfs|btrfs|jfs|zfs) 
            overlay_mount "$PART"
        ;;

        *)
            direct_mount "$PART"
        ;;
    esac
fi

echo "mount completed!"
