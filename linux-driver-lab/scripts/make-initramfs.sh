#!/bin/bash
set -e

ROOTFS="/lab/initramfs-root"
INITRAMFS="/lab/initramfs.cpio"
BUSYBOX=$(which busybox)

echo "========================================"
echo " Building initramfs (minimal rootfs)"
echo "========================================"
echo ""

if [ ! -f "/lab/kernel-build/arch/arm64/boot/Image" ]; then
    echo "ERROR: Kernel not built. Run build-kernel.sh first."
    exit 1
fi

echo "[1/5] Creating rootfs directory structure..."
rm -rf "${ROOTFS}"
mkdir -p "${ROOTFS}"/{bin,sbin,etc,proc,sys,dev,tmp,root,lib,mnt}

echo "[2/5] Installing busybox..."
cp "${BUSYBOX}" "${ROOTFS}/bin/busybox"
chmod +x "${ROOTFS}/bin/busybox"

cd "${ROOTFS}/bin"
for applet in $(./busybox --list); do
    if [ "${applet}" != "busybox" ]; then
        ln -sf busybox "${applet}" 2>/dev/null || true
    fi
done
cd /lab

echo "[3/5] Creating init script..."
cat > "${ROOTFS}/init" << 'INITEOF'
#!/bin/busybox sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev 2>/dev/null || mdev -s

echo ""
echo "====================================="
echo " Linux Driver Lab - QEMU VM"
echo "====================================="
echo ""

# Auto-load modules if present
for mod in /modules/*.ko; do
    if [ -f "$mod" ]; then
        echo "[init] Loading module: $mod"
        insmod "$mod"
    fi
done

# Show dmesg
echo "--- dmesg (last 20 lines) ---"
dmesg | tail -20
echo "--- end dmesg ---"
echo ""

echo "Available commands: insmod, rmmod, lsmod, dmesg, cat, echo, ls, cd"
echo "Module files in /modules/"
echo ""

# Start shell
exec /bin/sh
INITEOF
chmod +x "${ROOTFS}/init"

echo "[4/5] Copying compiled modules..."
mkdir -p "${ROOTFS}/modules"
for mod in /lab/modules/*/*.ko; do
    if [ -f "$mod" ]; then
        mod_name=$(basename "$mod")
        cp "$mod" "${ROOTFS}/modules/${mod_name}"
        echo "       - ${mod_name}"
    fi
done
if [ -z "$(ls -A ${ROOTFS}/modules 2>/dev/null)" ]; then
    echo "       (no .ko files found, you can compile them later)"
fi

echo "[5/5] Packing initramfs.cpio..."
cd "${ROOTFS}"
find . | cpio -H newc -o | gzip > "${INITRAMFS}.gz" 2>/dev/null
# Also create uncompressed version (some QEMU configs prefer this)
find . | cpio -H newc -o > "${INITRAMFS}" 2>/dev/null
cd /lab

echo ""
echo "========================================"
echo " initramfs build complete!"
echo "========================================"
echo "  File: ${INITRAMFS}"
echo "  Size: $(du -h ${INITRAMFS} | cut -f1)"
echo ""
echo "  Next: run run-qemu.sh"
echo "========================================"
