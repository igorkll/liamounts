#!/bin/bash

exec >> /var/log/liamounts.log 2>&1

PART="$1"
echo "liamounts umount: $PART"

process_paths() {
    local automounts_path="$2"
    local realmounts_path="$1"
    
    echo "automounts path: $automounts_path"
    echo "realmounts path: $realmounts_path"

    umount "$automounts_path"
    rmdir "$automounts_path"

    umount "$realmounts_path"
    rmdir "$realmounts_path"
}

findmnt -l -o TARGET --source "$PART" -n | while read path; do
    if [[ "$path" == /realmounts/* ]]; then
        name="${path#/realmounts/}"
        process_paths "$path" "/automounts/$name"
    elif [[ "$path" == /automounts/* ]]; then
        name="${path#/automounts/}"
        process_paths "/realmounts/$name" "$path"
    fi
done

echo "umount completed!"
