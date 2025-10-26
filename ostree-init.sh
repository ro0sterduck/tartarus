#!/usr/bin/env bash
set -euo pipefail

TARGET=$(realpath ../rootfs)
REPO="${REPO:-https://mirror.meowsmp.net/voidlinux/current}"
BRANCH=tartarus/base

cd $TARGET

OSTREPO=./ostree/repo

mkdir -p "$OSTREPO"

sudo ostree --repo="$OSTREPO" init
sudo ostree --repo="$OSTREPO" commit --branch="$BRANCH" "$TARGET" --subject="Tartarus base commit."
echo "Committed $TARGET to $OSTREPO branch $BRANCH"
