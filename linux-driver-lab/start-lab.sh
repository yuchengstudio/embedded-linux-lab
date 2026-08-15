#!/bin/bash
#
# Linux Driver Lab - Quick Start Script
# Run this on your Mac to start the development environment
#
# Usage:
#   ./start-lab.sh          - Start interactive container
#   ./start-lab.sh build    - Build image first, then start
#   ./start-lab.sh auto     - Auto-run: build kernel + modules + initramfs + QEMU
#

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="linux-driver-lab:latest"

echo "========================================"
echo " Linux Driver Development Lab"
echo "========================================"
echo ""

# Check Docker
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running. Please start Docker Desktop first."
    exit 1
fi

# Build image if requested or if it doesn't exist
if [ "$1" = "build" ] || ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    echo "[1/2] Building Docker image..."
    docker build -t "${IMAGE_NAME}" "${LAB_DIR}"
    if [ $? -ne 0 ]; then
        echo "ERROR: Image build failed."
        exit 1
    fi
    echo "[1/2] Image built successfully."
    echo ""
else
    echo "[1/2] Image already exists: ${IMAGE_NAME}"
fi

# Create persistent directories
mkdir -p "${LAB_DIR}/kernel-build" "${LAB_DIR}/initramfs-root"

# Auto mode: run everything automatically
if [ "$1" = "auto" ]; then
    echo "[2/2] Running auto-setup (kernel build + modules + QEMU)..."
    echo ""
    docker run --rm -it \
        -v "${LAB_DIR}/modules:/lab/modules" \
        -v "${LAB_DIR}/kernel-build:/lab/kernel-build" \
        -v "${LAB_DIR}/initramfs-root:/lab/initramfs-root" \
        -w /lab \
        "${IMAGE_NAME}" \
        /bin/bash -c '
            echo "=== Step 1: Build Kernel ==="
            build-kernel.sh
            echo ""
            echo "=== Step 2: Compile Modules ==="
            compile-module.sh /lab/modules/hello
            compile-module.sh /lab/modules/chardev
            echo ""
            echo "=== Step 3: Build initramfs ==="
            make-initramfs.sh
            echo ""
            echo "=== Step 4: Boot QEMU ==="
            echo "Press Ctrl+A then X to exit QEMU"
            run-qemu.sh
        '
    exit 0
fi

# Interactive mode
echo "[2/2] Starting interactive container..."
echo ""
echo "Inside the container, run:"
echo "  build-kernel.sh      - Build Linux kernel (first time, ~15 min)"
echo "  compile-module.sh    - Compile kernel modules"
echo "  make-initramfs.sh    - Build rootfs"
echo "  run-qemu.sh          - Boot QEMU and test"
echo ""
echo "Type 'exit' to leave the container."
echo "========================================"
echo ""

docker run --rm -it \
    -v "${LAB_DIR}/modules:/lab/modules" \
    -v "${LAB_DIR}/kernel-build:/lab/kernel-build" \
    -v "${LAB_DIR}/initramfs-root:/lab/initramfs-root" \
    -w /lab \
    "${IMAGE_NAME}" \
    /bin/bash
