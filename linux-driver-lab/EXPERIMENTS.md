# Linux Driver Lab - 实验对照表

> 基于《嵌入式Linux设备驱动程序开发指南（原书第2版）》
> 作者：Alberto Liberal de los Rios | 机械工业出版社 2021

## 使用方法

1. 在 Mac 上用 VSCode 编辑 `modules/` 下的代码
2. 在 Docker 容器内编译、打包、QEMU 测试
3. 实验结果记录到读书实验台 HTML 工作台

## 章节-实验对照（全书30个实验）

| 实验编号 | 实验名称 | 章节 | 关键API | Docker Lab 操作 | 书中代码清单 |
|---------|---------|------|---------|----------------|-------------|
| 3-1 | helloworld模块 | 第3章 | module_init, pr_info, MODULE_LICENSE | `compile-module.sh /lab/modules/hello` | 代码清单3-1 |
| 3-2 | 带参数的helloworld | 第3章 | module_param, charp | `compile-module.sh /lab/modules/hello` | 代码清单3-3 |
| 3-3 | helloworld计时 | 第3章 | ktime_get, ktime_to_ns | `compile-module.sh /lab/modules/hello` | 代码清单3-4 |
| 4-1 | helloworld字符设备 | 第4章 | register_chrdev, file_operations, copy_to/from_user | `compile-module.sh /lab/modules/chardev` | 代码清单4-1~4-3 |
| 4-2 | class字符设备 | 第4章 | class_create, device_create | `compile-module.sh /lab/modules/chardev` | 代码清单4-4 |
| 4-3 | 杂项字符设备 | 第4章 | misc_register, miscdevice, MISC_DYNAMIC_MINOR | `compile-module.sh /lab/modules/chardev` | 代码清单4-5 |
| 5-1 | 平台设备 | 第5章 | platform_driver_register, of_device_id, probe | 新建 modules/platform/ | 代码清单5-1 |
| 5-2 | RGB LED平台设备 | 第5章 | devm_gpiod_get, ioremap, readl/writel | 新建 modules/platform/ | 代码清单5-2 |
| 5-3 | RGB LED类 | 第5章 | led_classdev_register, brightness_set | 新建 modules/platform/ | 代码清单5-3 |
| 5-4 | LED UIO平台 | 第5章 | uio_register_device, UIO_MEM | 新建 modules/uio/ | 代码清单5-4~5-5 |
| 6-1 | I2C I/O扩展设备 | 第6章 | i2c_register_driver, i2c_transfer, i2c_msg | 新建 modules/i2c/ | 代码清单6-1 |
| 6-2 | I2C多显LED | 第6章 | sysfs_create_group, i2c_smbus_write_byte | 新建 modules/i2c/ | 代码清单6-2 |
| 7-1 | 按钮中断设备 | 第7章 | request_irq, free_irq, IRQF_TRIGGER | 新建 modules/irq/ | 代码清单7-1 |
| 7-2 | 睡眠设备 | 第7章 | wait_event_interruptible, wake_up, spinlock | 新建 modules/irq/ | 代码清单7-2 |
| 7-3 | keyled类 | 第7章 | kthread_create, kthread_run, workqueue | 新建 modules/irq/ | 代码清单7-3 |
| 8-1 | 链表内存分配 | 第8章 | kmalloc, kfree, list_head, list_add/del | 新建 modules/mem/ | 代码清单8-1 |
| 9-1 | 流式DMA | 第9章 | dma_map_single, dma_unmap_single | 新建 modules/dma/ | 代码清单9-1 |
| 9-2 | 分散/聚集DMA | 第9章 | dma_map_sg, scatterlist, sg_init_one | 新建 modules/dma/ | 代码清单9-2 |
| 9-3 | 用户态DMA | 第9章 | dma_buf_export, dma_buf_fd, mmap | 新建 modules/dma/ | 代码清单9-3~9-4 |
| 10-1 | 输入子系统加速度计 | 第10章 | input_allocate_device, input_report_abs | 新建 modules/input/ | 代码清单10-1 |
| 10-2 | SPI加速度计输入 | 第10章 | spi_register_driver, spi_sync, input_report_abs | 新建 modules/spi/ | 代码清单10-2 |
| 11-1 | IIO子系统DAC | 第11章 | devm_iio_device_alloc, iio_device_register | 新建 modules/iio/ | 代码清单11-1 |
| 11-2 | SPIDEV双通道ADC用户 | 第11章 | spidev, ioctl, SPI_IOC_MESSAGE | 用户态应用 | 代码清单11-2 |
| 11-3 | IIO子系统ADC | 第11章 | iio_chan_spec, iio_read_channel_raw | 新建 modules/iio/ | 代码清单11-3~11-4 |
| 11-4 | 硬件触发IIO ADC | 第11章 | iio_triggered_buffer_setup, iio_trigger | 新建 modules/iio/ | 代码清单11-5 |
| 12-1 | SPI regmap IIO设备 | 第12章 | regmap_init, regmap_read/write, devm_regmap_init_spi | 新建 modules/regmap/ | 代码清单12-1 |
| 13-1 | USB HID设备应用 | 第13章 | libusb, hid_open/write/read | 用户态应用 | 实验13-1 (13步) |
| 13-2 | USB LED | 第13章 | usb_register, usb_driver, usb_submit_urb | 新建 modules/usb/ | 代码清单13-1 |
| 13-3 | USB LED和开关 | 第13章 | usb_fill_int_urb, input_report_key | 新建 modules/usb/ | 代码清单13-2 |
| 13-4 | 连接USB多显LED的I2C | 第13章 | usb_driver, i2c_adapter, usb_to_i2c | 新建 modules/usb/ | 代码清单13-3 |

## QEMU 内常用命令

```bash
# 模块操作
insmod /modules/hello.ko        # 加载模块
rmmod hello                      # 卸载模块
lsmod                            # 查看已加载模块

# 调试
dmesg                            # 查看内核日志
dmesg | grep hello               # 过滤特定模块日志
dmesg | tail -20                 # 最近20条日志

# 字符设备测试
echo "test" > /dev/chardrv       # 写入
cat /dev/chardrv                 # 读取

# 文件系统
ls /dev/                         # 查看设备节点
ls /proc/                        # 查看proc文件系统
ls /sys/                         # 查看sysfs

# 退出 QEMU
# 按 Ctrl+A 然后按 X
```

## 开发循环

```
Mac VSCode 编辑 .c 文件
        |
        v
docker exec 进入容器 (或 start-lab.sh)
        |
        v
compile-module.sh /lab/modules/xxx    # 编译 .ko
        |
        v
make-initramfs.sh                      # 重新打包 rootfs
        |
        v
run-qemu.sh                            # 启动 QEMU
        |
        v
QEMU 内: insmod / dmesg / 测试
        |
        v
Ctrl+A, X 退出 QEMU
        |
        v
回到 Mac 修改代码，循环
```

## 模块代码模板

新建模块时复制此模板：

```c
#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

static int __init my_init(void)
{
    printk(KERN_INFO "my module loaded\n");
    return 0;
}

static void __exit my_exit(void)
{
    printk(KERN_INFO "my module unloaded\n");
}

module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("same54");
MODULE_DESCRIPTION("Module Description");
```

对应 Makefile：
```makefile
obj-m += mymodule.o

KDIR ?= /lab/kernel-build

all:
	make -C /lab/linux-$(KERNEL_VERSION) O=$(KDIR) ARCH=arm64 M=$(PWD) modules

clean:
	make -C /lab/linux-$(KERNEL_VERSION) O=$(KDIR) ARCH=arm64 M=$(PWD) clean
```
