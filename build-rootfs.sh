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

sudo echo "# placeholder" > "$TARGET"/etc/fstab
sudo echo "Rootfs built at $TARGET"

sudo ostree --repo="$OSTREPO" init
sudo ostree --repo="$OSTREPO" commit --branch="$BRANCH" "$TARGET" --subject="Tartarus base commit."
echo "Committed $TARGET to $OSTREPO branch $BRANCH"
