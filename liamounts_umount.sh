#!/bin/bash

exec >> /var/log/liamounts.log 2>&1

PART="$1"
echo "liamounts umount: $PART"



echo "umount completed!"
