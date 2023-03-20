# 03/13

### upgrade config
- `/rootfs/linux-5.12.1 ../20-make-oldconfig.sh`

### menu config --option
- `/rootfs/linux-5.12.1 ../21-make-menuconfig.sh`

### compile config
- `/rootfs/linux-5.12.1 ../30-make-kernel-modules.sh`
- output `Make kernel/modules Done!`, mean sucessed.


# 03/20

### linux 開機必要2個檔案
- /boot/kernel
- /boot/initrd