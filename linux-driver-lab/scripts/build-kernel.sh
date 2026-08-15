#!/bin/bash
set -e

KERNEL_VERSION="${KERNEL_VERSION:-6.1}"
KERNEL_SRC="/lab/linux-${KERNEL_VERSION}"
KERNEL_TARBALL="linux-${KERNEL_VERSION}.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_VERSION%%.*}.x/${KERNEL_TARBALL}"

echo "========================================"
echo " Building Linux Kernel ${KERNEL_VERSION} (arm64)"
echo "========================================"
echo ""

if [ -f "/lab/kernel-build/arch/arm64/boot/Image" ]; then
    echo "[OK] Kernel already built at /lab/kernel-build/arch/arm64/boot/Image"
    echo "     To rebuild, delete /lab/kernel-build and run this script again."
    exit 0
fi

if [ ! -d "${KERNEL_SRC}" ]; then
    echo "[1/4] Downloading kernel source..."
    if [ -f "/lab/${KERNEL_TARBALL}" ]; then
        echo "      Tarball already exists, skipping download."
    else
        wget -q --show-progress "${KERNEL_URL}" -O "/lab/${KERNEL_TARBALL}"
    fi
    echo "      Extracting..."
    tar xf "/lab/${KERNEL_TARBALL}" -C /lab/
else
    echo "[1/4] Kernel source already exists."
fi

BUILD_DIR="/lab/kernel-build"
mkdir -p "${BUILD_DIR}"

echo "[2/4] Configuring kernel (defconfig for arm64)..."
cd "${KERNEL_SRC}"
make O="${BUILD_DIR}" defconfig ARCH=arm64

echo "      Enabling module support and key features..."
cat >> "${BUILD_DIR}/.config" << 'EOF'
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_PROC_FS=y
CONFIG_SYSFS=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_TMPFS=y
CONFIG_PRINTK=y
CONFIG_FUTEX=y
CONFIG_SHMEM=y
EOF
make O="${BUILD_DIR}" olddefconfig ARCH=arm64

echo "[3/4] Compiling kernel (this takes 10-20 minutes)..."
make O="${BUILD_DIR}" -j"$(nproc)" ARCH=arm64 Image modules 2>&1 | tail -5

echo "[4/4] Verifying build..."
if [ -f "${BUILD_DIR}/arch/arm64/boot/Image" ]; then
    echo ""
    echo "========================================"
    echo " Kernel build complete!"
    echo "========================================"
    echo "  Image:  ${BUILD_DIR}/arch/arm64/boot/Image"
    echo "  Source: ${KERNEL_SRC}"
    echo ""
    echo "  Next: run make-initramfs.sh"
    echo "========================================"
else
    echo "ERROR: Kernel build failed. Image not found."
    exit 1
fi
