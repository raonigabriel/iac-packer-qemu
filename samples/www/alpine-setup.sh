#!/bin/sh

set -x

export BOOTLOADER=grub
export ROOTFS=xfs
export DISKOPTS='-L -s 512 -m sys /dev/vda'

setup-keymap us us
setup-hostname alpine
setup-timezone -z America/New_York

setup-interfaces -i <<EOF
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
EOF

echo "root:alpine" | chpasswd

setup-apkrepos http://dl-cdn.alpinelinux.org/alpine/v3.13/main

apk add --quiet openssh xfsprogs e2fsprogs xfsprogs-extra
rc-update --quiet add sshd default
sed -i 's/.*#PermitRootLogin prohibit-password*/PermitRootLogin yes/' /etc/ssh/sshd_config

rc-update --quiet add networking boot
rc-update --quiet add urandom boot

ERASE_DISKS=/dev/vda setup-disk -L -s 512 -m sys /dev/vda

reboot
