#!/bin/bash

exec >> /var/log/liamounts.log 2>&1

PART="$1"
echo "liamounts umount: $PART"

findmnt -l -o TARGET --source "$PART" -n | while read path; do
    echo "$path"
done

echo "umount completed!"
