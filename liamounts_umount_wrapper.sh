#!/bin/bash

exec 9>/run/liamounts.lock
flock 9

echo "/usr/local/bin/liamounts_umount.sh $1" | at now
