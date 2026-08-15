#!/bin/bash
set -e

KERNEL_IMAGE="/lab/kernel-build/arch/arm64/boot/Image"
INITRAMFS="/lab/initramfs.cpio"

echo "========================================"
echo " Booting QEMU (aarch64)"
echo "========================================"
echo ""

if [ ! -f "${KERNEL_IMAGE}" ]; then
    echo "ERROR: Kernel image not found. Run build-kernel.sh first."
    exit 1
fi

if [ ! -f "${INITRAMFS}" ]; then
    echo "ERROR: initramfs not found. Run make-initramfs.sh first."
    exit 1
fi

echo "Kernel:   ${KERNEL_IMAGE}"
echo "Rootfs:   ${INITRAMFS}"
echo "Machine:  virt"
echo "CPU:      cortex-a72"
echo "Memory:   512M"
echo ""
echo "To exit QEMU: press Ctrl+A then X"
echo "========================================"
echo ""

exec qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a72 \
    -m 512M \
    -kernel "${KERNEL_IMAGE}" \
    -initrd "${INITRAMFS}" \
    -append "console=ttyAMA0 rdinit=/init" \
    -nographic \
    -no-reboot
