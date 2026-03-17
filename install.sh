#!/bin/bash

mkdir -p /realmounts
chmod 0700 /realmounts

mkdir -p /automounts
chmod 0755 /automounts

cp 99-liamounts.rules /etc/udev/rules.d/99-liamounts.rules
cp liamounts_mount.sh /usr/bin/liamounts_mount.sh
