#!/bin/bash

exec >> /var/log/liamounts.log 2>&1

echo "liamounts umount"

for dir in /automounts/*; do
    [ -d "$dir" ] || continue
    
    echo "check for umount: $dir"
    if ! ls "$dir" >/dev/null 2>&1; then
        umount -l "$dir"
        rmdir "$dir"
    fi
done

for dir in /realmounts/*; do
    [ -d "$dir" ] || continue
    
    echo "check for umount: $dir"
    if ! ls "$dir" >/dev/null 2>&1; then
        umount -l "$dir"
        rmdir "$dir"
    fi
done

echo "umount completed!"
