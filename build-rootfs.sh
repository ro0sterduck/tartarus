#!/usr/bin/env bash
set -euo pipefail
TARGET=$(realpath ./rootfs)
REPO="${REPO:-https://mirror.meowsmp.net/voidlinux/current}"
mkdir -p $TARGET/{bin,sbin,usr/{bin,sbin},etc/xbps.d}
echo repository=$REPO > $TARGET/etc/xbps.d/00-repository.conf
sudo xbps-install -Syu --rootdir "$TARGET"
sudo xbps-install -y --rootdir "$TARGET" busybox xbps linux linux-headers busybox dinit ostree
echo "# placeholder" > "$TARGET"/etc/fstab
