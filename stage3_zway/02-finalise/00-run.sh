#!/bin/bash -e

# Убираем флаг no_connection для ZBW
on_chroot << EOF
echo "Удаляем флаг no_connection для ZBW..."
rm /etc/zbw/flags/no_connection || echo "Флаг no_connection не найден."


echo "Останавливаем службу z-way-server..."
/etc/init.d/z-way-server stop || echo "Ошибка при остановке z-way-server."

# Цикл для проверки процесса z-way-server
while pgrep -x "z-way-server" > /dev/null; do
    echo "Ожидаем остановки z-way-server..."
    sleep 1
done
echo "z-way-server успешно остановлен."

echo "Останавливаем службу zbw_connect..."
/etc/init.d/zbw_connect stop || echo "Ошибка при остановке zbw_connect."

# Цикл для проверки процесса zbw_connect
while pgrep -x "zbw_connect" > /dev/null; do
    echo "Ожидаем остановки zbw_connect..."
    sleep 1
done
echo "zbw_connect успешно остановлен."

echo "Останавливаем службу mongoose..."
/etc/init.d/mongoose stop || echo "Ошибка при остановке mongoose."

# Цикл для проверки процесса mongoose
while pgrep -x "mongoose" > /dev/null; do
    echo "Ожидаем остановки mongoose..."
    sleep 1
done
echo "mongoose успешно остановлен."

#echo "Проверяем статус всех служб..."
#service --status-all

#echo "Проверяем, освободился ли /dev..."
#fuser -vm /dev

#echo "Получаем список запущенных процессов (после остановки служб)..."
#ps aux

# Принудительно останавливаем start-stop-daemon и mongoose
echo "Принудительно останавливаем start-stop-daemon..."
pkill -f start-stop-daemon || true
sleep 2

# Повторная проверка активных процессов
#echo "Повторная проверка активных процессов..."
#ps aux

echo "Отключаем службу serial-getty@ttyAMA0.service"
systemctl mask serial-getty@ttyAMA0.service

echo "Отключаем Bluetooth"
systemctl disable bluetooth.service
for str in "dtoverlay=disable-bt" "enable_uart=1" "dtoverlay=pi3-miniuart-bt"; do
    if ! grep -q "$str" "/boot/config.txt"; then
        echo "$str" >> "/boot/config.txt"
    fi
done

EOF

# Путь к файлу конфигурации
CONFIG_FILE="${ROOTFS_DIR}/boot/config.txt"

echo "Проверка файла: $CONFIG_FILE"

# Строки для добавления, если их нет в файле
STRINGS=("dtoverlay=disable-bt" "enable_uart=1" "dtoverlay=pi3-miniuart-bt")

# Функция для проверки и добавления строки, если она отсутствует
check_and_add() {
    if grep -q "$1" "$CONFIG_FILE"; then
        echo "Строка уже существует: $1"
    else
        echo "Добавляем строку: $1"
        echo "$1" >> "$CONFIG_FILE"
    fi
}

# Проходим по каждой строке и проверяем её наличие
for str in "${STRINGS[@]}"; do
    check_and_add "$str"
done

echo "Обновление файла $CONFIG_FILE завершено."



















echo "Процессы успешно остановлены, продолжаем сборку..."
