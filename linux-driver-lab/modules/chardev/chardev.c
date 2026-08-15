#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/miscdevice.h>
#include <linux/uaccess.h>
#include <linux/mutex.h>

#define DEVICE_NAME "chardrv"
#define BUFFER_SIZE 256

static char device_buffer[BUFFER_SIZE];
static int buffer_len = 0;
static DEFINE_MUTEX(dev_lock);
static int open_count = 0;

static int chardrv_open(struct inode *inode, struct file *file)
{
    mutex_lock(&dev_lock);
    open_count++;
    printk(KERN_INFO "[chardrv] Device opened (open count: %d)\n", open_count);
    mutex_unlock(&dev_lock);
    return 0;
}

static int chardrv_release(struct inode *inode, struct file *file)
{
    mutex_lock(&dev_lock);
    open_count--;
    printk(KERN_INFO "[chardrv] Device closed (open count: %d)\n", open_count);
    mutex_unlock(&dev_lock);
    return 0;
}

static ssize_t chardrv_read(struct file *file, char __user *ubuf,
                             size_t count, loff_t *ppos)
{
    int bytes_to_read;
    int ret;

    mutex_lock(&dev_lock);

    if (*ppos >= buffer_len) {
        mutex_unlock(&dev_lock);
        return 0;
    }

    bytes_to_read = min(count, (size_t)(buffer_len - *ppos));

    ret = copy_to_user(ubuf, device_buffer + *ppos, bytes_to_read);
    if (ret) {
        mutex_unlock(&dev_lock);
        return -EFAULT;
    }

    *ppos += bytes_to_read;
    printk(KERN_INFO "[chardrv] Read %d bytes (pos=%lld)\n", bytes_to_read, *ppos);

    mutex_unlock(&dev_lock);
    return bytes_to_read;
}

static ssize_t chardrv_write(struct file *file, const char __user *ubuf,
                              size_t count, loff_t *ppos)
{
    int bytes_to_write;
    int ret;

    mutex_lock(&dev_lock);

    bytes_to_write = min(count, (size_t)(BUFFER_SIZE - *ppos));
    if (bytes_to_write == 0) {
        mutex_unlock(&dev_lock);
        return -ENOSPC;
    }

    ret = copy_from_user(device_buffer + *ppos, ubuf, bytes_to_write);
    if (ret) {
        mutex_unlock(&dev_lock);
        return -EFAULT;
    }

    *ppos += bytes_to_write;
    if (*ppos > buffer_len)
        buffer_len = *ppos;

    printk(KERN_INFO "[chardrv] Wrote %d bytes (pos=%lld, total=%d)\n",
           bytes_to_write, *ppos, buffer_len);

    mutex_unlock(&dev_lock);
    return bytes_to_write;
}

static const struct file_operations chardrv_fops = {
    .owner   = THIS_MODULE,
    .open    = chardrv_open,
    .release = chardrv_release,
    .read    = chardrv_read,
    .write   = chardrv_write,
    .llseek  = default_llseek,
};

static struct miscdevice chardrv_dev = {
    .minor = MISC_DYNAMIC_MINOR,
    .name  = DEVICE_NAME,
    .fops  = &chardrv_fops,
};

static int __init chardrv_init(void)
{
    int ret;

    ret = misc_register(&chardrv_dev);
    if (ret) {
        printk(KERN_ERR "[chardrv] Failed to register device\n");
        return ret;
    }

    memset(device_buffer, 0, BUFFER_SIZE);
    buffer_len = 0;

    printk(KERN_INFO "========================================\n");
    printk(KERN_INFO " Character Device Driver Loaded!\n");
    printk(KERN_INFO "   - Device: /dev/%s\n", DEVICE_NAME);
    printk(KERN_INFO "   - Buffer: %d bytes\n", BUFFER_SIZE);
    printk(KERN_INFO "   - APIs:   open/read/write/close\n");
    printk(KERN_INFO "========================================\n");
    printk(KERN_INFO "[chardrv] Try: echo hello > /dev/%s\n", DEVICE_NAME);
    printk(KERN_INFO "[chardrv] Then: cat /dev/%s\n", DEVICE_NAME);

    return 0;
}

static void __exit chardrv_exit(void)
{
    misc_deregister(&chardrv_dev);
    printk(KERN_INFO "[chardrv] Device unregistered\n");
}

module_init(chardrv_init);
module_exit(chardrv_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Driver Lab");
MODULE_DESCRIPTION("Character Device Driver - Chapter 3 Experiment");
