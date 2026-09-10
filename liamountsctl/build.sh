#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Restart with root..."
    exec sudo "$0" "$@"
    exit $?
fi

gcc liamountsctl.c -o liamountsctl \
    -O2 \
    -Wall -Wextra \
    -fstack-protector-strong \
    -fPIE -pie \
    -D_FORTIFY_SOURCE=2 \
    -Wl,-z,relro,-z,now \
    -Wl,-z,noexecstack \
    -Wl,-z,separate-code

chown root:root liamountsctl
chmod +s liamountsctl # yes... is suid
