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

