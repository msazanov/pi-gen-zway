#!/bin/bash -e

# The '-e' flag causes the script to exit immediately if any command exits with a non-zero status.

on_chroot << EOF
# The 'on_chroot' command is used to execute the following commands inside the chroot environment.

# Remove the 'no_connection' flag file if it exists. Print a message if the file is not found.
rm /etc/zbw/flags/no_connection || echo "no_connection flag not found."

# Attempt to stop the z-way-server. Print a message if it can't be stopped.
/etc/init.d/z-way-server stop || echo "Cant stop z-way-server."

# Wait until the z-way-server process has stopped.
while pgrep -x "z-way-server" > /dev/null; do
    echo "Waiting to stop z-way-server..."
    sleep 1
done
echo "z-way-server was stopped."

# Repeat the stop and wait process for zbw_connect and mongoose services.
/etc/init.d/zbw_connect stop || echo "Cant stop zbw_connect."
while pgrep -x "zbw_connect" > /dev/null; do
    echo "Waiting to stop zbw_connect..."
    sleep 1
done
echo "zbw_connect was stopped."

/etc/init.d/mongoose stop || echo "Cant stop mongoose."
while pgrep -x "mongoose" > /dev/null; do
    echo "Waiting to stop mongoose..."
    sleep 1
done
echo "mongoose was stopped."

# Force kill the start-stop-daemon process if it's still running.
echo "Force kill start-stop-daemon..."
pkill -f start-stop-daemon || true
sleep 2

# Disable serial-getty service on ttyAMA0.
echo "Disable service serial-getty@ttyAMA0.service"
systemctl mask serial-getty@ttyAMA0.service

# Disable the Bluetooth service.
echo "Disable Bluetooth"
systemctl disable bluetooth.service

echo "dtoverlay=disable-bt" >> "/boot/firmware/config.txt"
echo "enable_uart=1" >> "/boot/firmware/config.txt"
echo "dtoverlay=pi3-miniuart-bt" >> "/boot/firmware/config.txt"


# Display the last six lines of the config file.
echo "Last six lines of the config file:"
tail -n 6 "/boot/firmware/config.txt"

EOF
