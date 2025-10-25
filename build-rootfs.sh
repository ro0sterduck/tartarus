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
sudo xbps-install -y --rootdir "$TARGET" xbps linux linux-headers dinit ostree

git clone https://github.com/mirror/busybox.git --depth 1
cd busybox
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' .config
make -j$(nproc)
make install CONFIG_PREFIX="$TARGET"

echo "# placeholder" > "$TARGET"/etc/fstab
echo "Rootfs built at $TARGET"

sudo ostree --repo="$OSTREPO" init
sudo ostree --repo="$OSTREPO" commit --branch="$BRANCH" "$TARGET" --subject="Tartarus base commit."
echo "Committed $TARGET to $OSTREPO branch $BRANCH"
