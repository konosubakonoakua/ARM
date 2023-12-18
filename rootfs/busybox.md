# busybox rootfs

## download & build busybox

```shell
./busybox.sh
```

After the script successfully executed, we get `busybox/rootfs.img.gz`.

## run with qemu

```shell
qemu-system-arm \
  -M orangepi-pc \
  -nographic \
  -kernel /mnt/orangepipc.img/boot/zImage \
  -dtb /mnt/orangepipc.img/boot/dtb/sun8i-h3-orangepi-pc.dtb \
  -initrd rootfs.img.gz -append 'root=/dev/ram rdinit=/sbin/init'
```
