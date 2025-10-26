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
sudo xbps-install -y --rootdir "$TARGET" grub base-files coreutils findutils diffutils dash grep gzip sed gawk linux linux-headers util-linux which tar shadow procps-ng iana-etc xbps nvi tzdata dinit

cd $TARGET

echo "Ostree script running..."
exec ../ostree-init.sh &

sudo ln -s "$(sudo chroot . which dinit)" "$TARGET/sbin/init"

sudo mkdir -p "$TARGET/etc/dinit.d/boot.d"
sudo touch "$TARGET/etc/dinit.d/boot.d/agetty.service"

echo 'type=internal
command = /usr/bin/agetty' | sudo tee "$TARGET/etc/dinit.d/boot" > /dev/null

echo 'NAME=Tartarus
VERSION=1.0
ID=tartarus
PRETTY_NAME="Tartarus 1.0"
VERSION_ID=1.0' | sudo tee "$TARGET/usr/lib/os-release" > /dev/null

echo '# placeholder' | sudo tee "$TARGET/etc/fstab" > /dev/null
echo "Rootfs built at $TARGET"

echo "Ostree script running..."
cd $TARGET

sudo find . -print0 | sudo cpio --null -ov --format=newc | gzip -9 | sudo tee ../initramfs.cpio.gz > /dev/null

mkdir -p ../iso/{boot,efi,boot/grub}

cp $TARGET/boot/vmlinuz-* $TARGET/../iso/boot/vmlinuz

cd $TARGET/..

sudo cp initramfs.cpio.gz $TARGET/../iso/boot/initrd.img

touch $TARGET/../iso/boot/grub/grub.cfg
cat > $TARGET/../iso/boot/grub/grub.cfg <<'EOF'
set default=0
set timeout=3

menuentry "Tartarus (BIOS)" {
    linux /boot/vmlinuz root=/dev/ram0 initrd=/boot/initrd.img quiet
    initrd /boot/initrd.img
}
EOF

cd $TARGET/..

grub-mkrescue -o tartarus.iso iso
