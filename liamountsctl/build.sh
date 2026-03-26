#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Restart with root..."
    exec sudo "$0" "$@"
    exit $?
fi

gcc liamountsctl.c -o liamountsctl
chown root:root liamountsctl
chmod +s liamountsctl # yes... is suid
