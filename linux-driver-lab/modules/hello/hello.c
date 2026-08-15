#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

static int hello_count = 1;
module_param(hello_count, int, 0644);
MODULE_PARM_DESC(hello_count, "Number of times to print hello message");

static int __init hello_init(void)
{
    int i;
    printk(KERN_INFO "========================================\n");
    printk(KERN_INFO " Hello Kernel Module Loaded!\n");
    printk(KERN_INFO "   - Module: hello\n");
    printk(KERN_INFO "   - Count:  %d\n", hello_count);
    printk(KERN_INFO "   - PID:    %d\n", current->pid);
    printk(KERN_INFO "========================================\n");

    for (i = 0; i < hello_count; i++) {
        printk(KERN_INFO "  [%d] Hello, Embedded Linux World!\n", i + 1);
    }

    return 0;
}

static void __exit hello_exit(void)
{
    printk(KERN_INFO "Goodbye, Embedded Linux World! (hello module unloaded)\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Driver Lab");
MODULE_DESCRIPTION("Hello World Kernel Module - Chapter 2 Experiment");
