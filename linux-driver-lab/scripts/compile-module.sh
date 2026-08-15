#!/bin/bash
set -e

KERNEL_SRC="/lab/linux-${KERNEL_VERSION:-6.1}"
BUILD_DIR="/lab/kernel-build"

if [ ! -d "${BUILD_DIR}" ]; then
    echo "ERROR: Kernel build directory not found."
    echo "       Run build-kernel.sh first."
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: compile-module.sh <module_directory>"
    echo ""
    echo "Examples:"
    echo "  compile-module.sh /lab/modules/hello"
    echo "  compile-module.sh /lab/modules/chardev"
    echo ""
    echo "Available modules:"
    for dir in /lab/modules/*/; do
        if ls "${dir}"*.c >/dev/null 2>&1; then
            echo "  ${dir}"
        fi
    done
    exit 0
fi

MOD_DIR="$1"
if [ ! -d "${MOD_DIR}" ]; then
    echo "ERROR: Directory not found: ${MOD_DIR}"
    exit 1
fi

echo "========================================"
echo " Compiling module: $(basename ${MOD_DIR})"
echo "========================================"
echo ""

cd "${MOD_DIR}"
make -C "${KERNEL_SRC}" O="${BUILD_DIR}" ARCH=arm64 CROSS_COMPILE="" M="$(pwd)" modules 2>&1

echo ""
echo "========================================"
echo " Build complete!"
echo "========================================"

for ko in *.ko; do
    if [ -f "$ko" ]; then
        echo "  Output: ${MOD_DIR}/${ko}"
        echo "  Size:   $(du -h ${ko} | cut -f1)"
    fi
done

echo ""
echo "Next steps:"
echo "  1. Run make-initramfs.sh to rebuild rootfs with new module"
echo "  2. Run run-qemu.sh to boot and test"
echo "  3. Inside QEMU: insmod /modules/<module>.ko"
echo ""
