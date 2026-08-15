#!/bin/busybox sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev 2>/dev/null || mdev -s

echo ""
echo "====================================="
echo " Linux Driver Lab - QEMU VM"
echo "====================================="
echo ""

for mod in /modules/*.ko; do
    if [ -f "$mod" ]; then
        echo "[init] Loading module: $mod"
        insmod "$mod"
    fi
done

echo "--- dmesg (last 20 lines) ---"
dmesg | tail -20
echo "--- end dmesg ---"
echo ""

echo "Available commands: insmod, rmmod, lsmod, dmesg, cat, echo, ls, cd"
echo "Module files in /modules/"
echo ""

exec /bin/sh
