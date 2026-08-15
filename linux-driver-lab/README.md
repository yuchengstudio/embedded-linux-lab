# 嵌入式 Linux 驱动开发实验环境

基于 Docker + QEMU 在 macOS (Apple Silicon) 上搭建的 Linux 内核模块开发环境。

## 为什么用这个方案

| 问题 | 解决方案 |
|------|---------|
| macOS 不能直接编译/加载 Linux 内核模块 | Docker 容器提供完整 Linux 工具链 |
| 直接在 Docker VM 里 insmod 可能搞崩整个 Docker | QEMU 独立虚拟机，崩了只影响 QEMU |
| Apple Silicon (ARM64) 与书上 x86_64 不同 | 驱动 API 完全一致，ARM64 反而更贴合嵌入式实际场景 |

## 快速开始

### 1. 构建镜像并启动容器

```bash
cd linux-driver-lab

# 创建持久化目录（内核编译结果和 rootfs 会保存在这里）
mkdir -p kernel-build initramfs-root

# 构建并启动
docker compose run --rm driver-lab
```

### 2. 容器内：编译内核（首次，约 10-20 分钟）

```bash
build-kernel.sh
```

这一步会：
- 下载 Linux 6.1 LTS 内核源码（约 200MB）
- 配置 arm64 defconfig
- 编译内核和模块

编译结果保存在 `/lab/kernel-build/`，映射到宿主机的 `kernel-build/` 目录，下次启动容器不需要重新编译。

### 3. 容器内：编译示例模块

```bash
# 编译 hello 模块（第2章实验）
compile-module.sh /lab/modules/hello

# 编译 chardev 模块（第3章实验）
compile-module.sh /lab/modules/chardev
```

### 4. 容器内：构建 initramfs

```bash
make-initramfs.sh
```

这会创建一个包含 busybox + 你的 .ko 模块的最小根文件系统。

### 5. 容器内：启动 QEMU 虚拟机

```bash
run-qemu.sh
```

QEMU 启动后会自动加载 /modules/ 下的所有 .ko 模块，然后给你一个 shell。

### 6. QEMU 内：测试模块

```bash
# 查看 hello 模块输出
dmesg | grep Hello

# 测试字符设备
echo "test data" > /dev/chardrv
cat /dev/chardrv

# 查看已加载模块
lsmod

# 卸载模块
rmmod hello
rmmod chardev

# 重新加载
insmod /modules/hello.ko
```

**退出 QEMU**：按 `Ctrl+A`，然后按 `X`

## 完整开发流程

```
修改模块代码 (Mac 上用 VSCode)
       |
       v
compile-module.sh (容器内编译 .ko)
       |
       v
make-initramfs.sh (重新打包 rootfs)
       |
       v
run-qemu.sh (启动 QEMU 测试)
       |
       v
QEMU 内 insmod / dmesg / 测试
       |
       v
退出 QEMU (Ctrl+A, X)
       |
       v
回到 Mac 修改代码，循环迭代
```

## 目录结构

```
linux-driver-lab/
├── Dockerfile                 # Docker 镜像定义
├── docker-compose.yml         # 容器编排
├── init.sh                    # initramfs 的 init 脚本
├── scripts/
│   ├── build-kernel.sh        # 下载并编译 Linux 内核
│   ├── make-initramfs.sh      # 创建最小根文件系统
│   ├── compile-module.sh      # 编译内核模块
│   └── run-qemu.sh            # 启动 QEMU 虚拟机
├── modules/
│   ├── hello/
│   │   ├── hello.c            # 第2章实验：Hello World 模块
│   │   └── Makefile
│   └── chardev/
│       ├── chardev.c          # 第3章实验：字符设备驱动
│       └── Makefile
├── kernel-build/              # (运行时生成) 内核编译输出
└── initramfs-root/            # (运行时生成) rootfs 目录
```

## 新增你自己的模块

1. 在 `modules/` 下创建新目录：
```bash
mkdir modules/mydriver
```

2. 创建 `modules/mydriver/mydriver.c`，基本模板：
```c
#include <linux/module.h>
#include <linux/init.h>

static int __init mydriver_init(void)
{
    printk(KERN_INFO "mydriver loaded\n");
    return 0;
}

static void __exit mydriver_exit(void)
{
    printk(KERN_INFO "mydriver unloaded\n");
}

module_init(mydriver_init);
module_exit(mydriver_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("My Driver");
```

3. 创建 `modules/mydriver/Makefile`：
```makefile
obj-m += mydriver.o

KDIR ?= /lab/kernel-build

all:
	make -C /lab/linux-$(KERNEL_VERSION) O=$(KDIR) ARCH=arm64 M=$(PWD) modules

clean:
	make -C /lab/linux-$(KERNEL_VERSION) O=$(KDIR) ARCH=arm64 M=$(PWD) clean
```

4. 编译、打包、测试：
```bash
compile-module.sh /lab/modules/mydriver
make-initramfs.sh
run-qemu.sh
```

## 常见问题

**Q: 内核编译太慢？**
A: 首次编译约 10-20 分钟，之后编译结果会持久化到 `kernel-build/` 目录，不需要重复编译。

**Q: QEMU 启动后黑屏？**
A: 等几秒，内核启动需要时间。如果超过 30 秒还没输出，检查内核是否编译成功。

**Q: insmod 报版本不匹配？**
A: 确保模块是用同一个内核源码树编译的。如果重新编译了内核，也要重新编译所有模块。

**Q: 想用其他内核版本？**
A: 修改 `Dockerfile` 中的 `ENV KERNEL_VERSION=6.1`，然后重新构建镜像。

**Q: 如何在 Mac 上编辑代码但在容器里编译？**
A: `modules/` 目录已通过 volume 映射，在 Mac 上用 VSCode 编辑 `modules/` 下的文件，容器内会实时同步。
