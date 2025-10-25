#!/usr/bin/env bash
set -euo pipefail

TARGET=$(realpath ./rootfs)
REPO="${REPO:-https://mirror.meowsmp.net/voidlinux/current}"
ROOTFS=$(realpath ./rootfs)
BRANCH=tartarus/base

mkdir -p $TARGET/{bin,sbin,usr/{bin,sbin},etc/xbps.d}
mkdir -p $TARGET/ostree/repo

OSTREPO=$(realpath ./rootfs/ostree/repo)

echo repository=$REPO > $TARGET/etc/xbps.d/00-repository.conf
sudo xbps-install -Syu --rootdir "$TARGET"
sudo xbps-install -y --rootdir "$TARGET" busybox xbps linux linux-headers busybox dinit ostree
echo "# placeholder" > "$TARGET"/etc/fstab
echo "Rootfs built at $TARGET"

sudo ostree --repo="$OSTREPO" init
sudo ostree --repo="$OSTREPO" commit --branch="$BRANCH" "$ROOTFS" --subject="Tartarus base commit."
echo "Committed $ROOTFS to $OSTREPO branch $BRANCH"
