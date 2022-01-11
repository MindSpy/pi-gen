#!/bin/bash -e

install -m 644 files/sources.list "${ROOTFS_DIR}/etc/apt/"
install -m 644 files/raspi.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list"
sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list.d/raspi.list"

if [ -n "$APT_PROXY" ]; then
	install -m 644 files/51cache "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
	sed "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache" -i -e "s|APT_PROXY|${APT_PROXY}|"
else
	rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
fi

GPG_CMD="gpg --batch --yes --dearmor"
KEY_DIR="/usr/share/keyrings"

on_chroot -c "$GPG_CMD -o $KEY_DIR/raspbian.gpg" < files/raspbian.gpg.key
on_chroot -c "$GPG_CMD -o $KEY_DIR/raspberrypi.gpg" < files/raspberrypi.gpg.key

on_chroot << EOF
apt-get update
apt-get dist-upgrade -y
EOF
