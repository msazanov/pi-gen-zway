#!/bin/bash -e

# Debugging: Display information about adding the repository
echo "Adding z-wave-me.list repository file to ${ROOTFS_DIR}/etc/apt/sources.list.d/"
install -m 644 files/z-wave-me.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list.d/z-wave-me.list"

# Debugging: Check the contents of the repository file
#echo "Contents of the z-wave-me.list repository file:"
#cat "${ROOTFS_DIR}/etc/apt/sources.list.d/z-wave-me.list"

# Debugging: Adding and verifying the GPG key
echo "Adding GPG key"
cat files/z-wave-me.gpg.key | gpg --dearmor > "${STAGE_WORK_DIR}/z-wave-me.gpg"
install -m 644 "${STAGE_WORK_DIR}/z-wave-me.gpg" "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/"

#echo "Checking the added GPG key in ${ROOTFS_DIR}/etc/apt/trusted.gpg.d/"
#ls -l "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/"

echo "Adding support for armhf architecture"
on_chroot << EOF
dpkg --add-architecture armhf
apt-get update
EOF

echo "Adding no_connection flag for ZBW"
on_chroot << EOF
mkdir -p /etc/zbw/flags/
touch /etc/zbw/flags/no_connection
EOF

# Custom motd
rm -f "${ROOTFS_DIR}"/etc/motd
rm -f "${ROOTFS_DIR}"/etc/update-motd.d/10-uname
install -m 755 files/motd-RaZberry "${ROOTFS_DIR}"/etc/update-motd.d/10-razberry
