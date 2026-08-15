FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV KERNEL_VERSION=6.1

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    bc \
    flex \
    bison \
    libelf-dev \
    libssl-dev \
    qemu-system-arm \
    qemu-system-misc \
    busybox-static \
    cpio \
    wget \
    curl \
    git \
    vim \
    nano \
    kmod \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /lab

COPY scripts/ /lab/scripts/
COPY modules/ /lab/modules/
COPY init.sh /lab/init.sh

RUN chmod +x /lab/scripts/*.sh /lab/init.sh

RUN echo 'export PATH="/lab/scripts:$PATH"' >> /root/.bashrc && \
    echo 'PS1="\[\033[01;32m\]driver-lab\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /root/.bashrc && \
    echo 'echo ""' >> /root/.bashrc && \
    echo 'echo "====================================="' >> /root/.bashrc && \
    echo 'echo " Linux Driver Development Lab"' >> /root/.bashrc && \
    echo 'echo " Kernel: Linux $KERNEL_VERSION LTS (arm64)"' >> /root/.bashrc && \
    echo 'echo "====================================="' >> /root/.bashrc && \
    echo 'echo ""' >> /root/.bashrc && \
    echo 'echo "Quick start:"' >> /root/.bashrc && \
    echo 'echo "  1. build-kernel.sh     - compile Linux kernel (first time only)"' >> /root/.bashrc && \
    echo 'echo "  2. make-initramfs.sh    - build minimal rootfs"' >> /root/.bashrc && \
    echo 'echo "  3. compile-module.sh    - compile a kernel module"' >> /root/.bashrc && \
    echo 'echo "  4. run-qemu.sh          - boot QEMU and test modules"' >> /root/.bashrc && \
    echo 'echo ""' >> /root/.bashrc

CMD ["/bin/bash"]
