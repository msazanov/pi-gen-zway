#!/bin/bash -e

# Отладка: Вывод информации о добавлении репозитория
echo "Добавление файла репозитория z-wave-me.list в ${ROOTFS_DIR}/etc/apt/sources.list.d/"
install -m 644 files/z-wave-me.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"
sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list.d/z-wave-me.list"

# Отладка: Проверка содержимого файла репозитория
echo "Содержимое файла репозитория z-wave-me.list:"
cat "${ROOTFS_DIR}/etc/apt/sources.list.d/z-wave-me.list"

# Отладка: Добавление и проверка ключа GPG
echo "Добавление ключа GPG"
cat files/z-wave-me.gpg.key | gpg --dearmor > "${STAGE_WORK_DIR}/z-wave-me.gpg"
install -m 644 "${STAGE_WORK_DIR}/z-wave-me.gpg" "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/"

echo "Проверка добавленного ключа GPG в ${ROOTFS_DIR}/etc/apt/trusted.gpg.d/"
ls -l "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/"

# Отладка: Обновление списка пакетов в chroot
echo "Добавляем потдержку ахитектуры armhf"
on_chroot << EOF
dpkg --add-architecture armhf
apt-get update
EOF

echo "Добавляем флаг no_connection для ZBW"
on_chroot << EOF
mkdir -p /etc/zbw/flags/
touch /etc/zbw/flags/no_connection
EOF

# Custom motd
rm -f "${ROOTFS_DIR}"/etc/motd
rm -f "${ROOTFS_DIR}"/etc/update-motd.d/10-uname
install -m 755 files/motd-RaZberry "${ROOTFS_DIR}"/etc/update-motd.d/10-razberry


# Отладка завершена
echo "Скрипт завершил выполнение"
