obj-m += chardev.o

KDIR ?= /lab/kernel-build

all:
	make -C /lab/linux-$(KERNEL_VERSION) O=$(KDIR) ARCH=arm64 M=$(PWD) modules

clean:
	make -C /lab/linux-$(KERNEL_VERSION) O=$(KDIR) ARCH=arm64 M=$(PWD) clean
