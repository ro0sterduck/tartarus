#!/usr/bin/env bash
set -euo pipefail

TARGET=$(realpath ./rootfs)
REPO="${REPO:-https://mirror.meowsmp.net/voidlinux/current}"
BRANCH=tartarus/base

mkdir -p $TARGET/{bin,sbin,usr/{bin,sbin},etc/xbps.d}
mkdir -p $TARGET/ostree/repo

OSTREPO=$(realpath ./rootfs/ostree/repo)

echo repository=$REPO > $TARGET/etc/xbps.d/00-repository.conf
sudo xbps-install -Syu --rootdir "$TARGET"
sudo xbps-install -y --rootdir "$TARGET" base-system bash xbps ostree fastfetch linux linux-headers

cd $TARGET

exec ../ostree-init.sh &

echo 'NAME=Tartarus
VERSION=1.0
ID=tartarus
PRETTY_NAME="Tartarus 1.0"
VERSION_ID=1.0' | sudo tee "$TARGET/usr/lib/os-release" > /dev/null

echo '# placeholder' | sudo tee "$TARGET/etc/fstab" > /dev/null
echo "Rootfs built at $TARGET"

echo "Ostree script running..."
