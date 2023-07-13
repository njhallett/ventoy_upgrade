#!/bin/sh

# shellcheck disable=SC3037

set -e

command -v gh >/dev/null 2>&1 || {
    echo >&2 "I require gh but it's not installed.  Aborting."
    exit 1
}
command -v sudo >/dev/null 2>&1 || {
    echo >&2 "I require sudo but it's not installed.  Aborting."
    exit 1
}

dev=$(mount | grep Ventoy | cut -d ' ' -f 1 | grep -o '/dev/sd.')

if [ -z "$dev" ]; then
    echo "Ventoy device not found"
    exit 1
fi

echo "Ventoy device found: $dev"

cur_ver=$(sudo vtoycli fat "$dev""2")

if [ -z "$cur_ver" ]; then
    echo "Current version not found"
    exit 1
fi

echo "Current version: $cur_ver"

lat_ver=$(gh release list --repo ventoy/Ventoy | grep Latest | grep -o ' [0-9]\+\.[0-9]\+\.[0-9]\+ ' | awk '{$1=$1;print}')

if [ -z "$lat_ver" ]; then
    echo "Latest version not found"
    exit 1
fi

echo "Latest version: $lat_ver"

if [ "$cur_ver" = "$lat_ver" ]; then
    exit
fi

echo -n "Do you wish to download the upgrade? "
read -r yn

if [ "$yn" != "${yn#[Yy]}" ]; then

    if gh release download --repo ventoy/Ventoy --pattern '*-linux.tar.gz' --dir /tmp; then
        cd /tmp || exit

        if tar xfz ventoy-"$lat_ver"-linux.tar.gz; then
            cd ventoy-"$lat_ver" || exit
            sudo ./Ventoy2Disk.sh -u "$dev"
        fi

    fi

fi
