# qemu for arm

## orangepi-pc

QEMU official document [here](https://www.qemu.org/docs/master/system/arm/orangepi.html).

### buildroot

Use buildroot to generate working image for `orangepi_pc`.
After the build, we got images in `output/images`.

```shell
make orangepi_pc_defconfig
# append the two lines below to .config or set them in menuconfig/host utilitils
# BR2_PACKAGE_HOST_QEMU=y
# BR2_PACKAGE_HOST_QEMU_SYSTEM_MODE=y
make -j8
```

### qemu

- Maybe we need to resize the `sdcard.img` using `qemu-resize sdcard.img 128M`.
- We can find the pre-built image in [release page](https://github.com/konosubakonoakua/ARM/releases/tag/orangepi-pc-sd-img)
- We use telnet to redirect the `qemu monitor console` to `127.0.0.1:1234`, and surely we need to connect it by execute `telnet 127.0.0.1 123` in a new terminal.
- We add device (no hot-plug) by `-device <devicename>,bus=<bus>,address=<addr>`, in case that we want to know what kind of devices qemu-system-arm supports, use `qemu-system-arm -device ?`.

```shell
qemu-system-arm -M orangepi-pc \
  -m 1G \
  -sd sdcard.img \
  -serial stdio \
  -monitor telnet:127.0.0.1:1234,server,nowait \
  -device i2c-echo,address=0x33 \
  -device ssd0303,address=0x3c
```

In case we do not want to load u-boot:

```shell
# only load kernel & rootfs, use qemu default orangepi bootloader
IMAGE_DIR="."
qemu-system-arm \
 -M orangepi-pc \
 -m 1G \
 -nographic \
 -kernel ${IMAGE_DIR}/zImage \
 -dtb ${IMAGE_DIR}/sun8i-h3-orangepi-pc.dtb \
 -sd sdcard.img -append "console=ttyS0,115200 rootwait root=/dev/mmcblk0p1" \
 # -drive file=${IMAGE_DIR}/rootfs.ext2,if=sd,format=raw -append "console=ttyS0,115200 rootwait root=/dev/mmcblk0" \
 # -drive if=none,id=stick,file=sdcard.img -device usb-storage,bus=usb-bus.0,drive=stick \
 # -nic user \
 # -gdb tcp::12451 \
 # -S \
```

In case we want to boot in different storage:

```shell
# boot with sdcard image, use `root=/dev/mmcblk0p1`, aka partition 1, since formatted.
-sd sdcard.img -append "console=ttyS0,115200 rootwait root=/dev/mmcblk0p1" \

# boot with rootfs, use `root=/dev/mmcblk0` since `format=raw`.
-drive file=${IMAGE_DIR}/rootfs.ext2,if=sd,format=raw -append "console=ttyS0,115200 rootwait root=/dev/mmcblk0" \

# boot with usb-stick, `not tested`.
-drive if=none,id=stick,file=sdcard.img -device usb-storage,bus=usb-bus.0,drive=stick \
```

### qemu monitor console

Don't forget to telnet to the qemu monitor console.

```shell
# execute in a new terminal
telnet 127.0.0.1 1234
```

After we successfully connect to monitor console, we can use `info qtree` to find out what devices or buses we can use for current machine.

```shell
# execute in qemu monitor console
info qtree

# we'll get something below
##################################
#  dev: allwinner.i2c-sun6i, id ""
#    gpio-out "sysbus-irq" 1
#    mmio 0000000001f02400/0000000000000024
#    bus: i2c
#      type i2c-bus
#      dev: ssd0303, id ""
#        address = 0 (0x0)
#      dev: i2c-echo, id ""
#        address = 0 (0x0)
###################################

```
