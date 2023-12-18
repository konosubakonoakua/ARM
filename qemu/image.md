# image

## image download

```shell
wget https://mirrors.aliyun.com/armbian-releases/orangepizero/archive/Armbian_23.11.1_Orangepizero_bookworm_current_6.1.63.img.xz
wget https://mirrors.bfsu.edu.cn/armbian-releases/orangepipc/archive/Armbian_23.11.1_Orangepipc_bookworm_current_6.1.63.img.xz
```

## image extraction

`tar -Jxvf` not working!!! Wired.
Use `unxz` instead.
Resize the image if necessary.

```shell
qemu-img resize Armbian_23.11.1_Orangepipc_bookworm_current_6.1.63.img 2G
```

## image mount

```shell
fdisk -l Armbian_23.11.1_Orangepipc_bookworm_current_6.1.63.img
  #Disk Armbian_23.11.1_Orangepipc_bookworm_current_6.1.63.img: 2 GiB, 2147483648 bytes, 4194304 sectors
  #Units: sectors of 1 * 512 = 512 bytes
  #Sector size (logical/physical): 512 bytes / 512 bytes
  #I/O size (minimum/optimal): 512 bytes / 512 bytes
  #Disklabel type: dos
  #Disk identifier: 0xd5584962
  #
  #Device                                                  Boot Start     End Sectors  Size Id Type
  #Armbian_23.11.1_Orangepipc_bookworm_current_6.1.63.img1       8192 3964928 3956737  1.9G 83 Linux

sudo mkdir -p /mnt/orangepipc.img
# offset=start_sector*sector_size
sudo mount -o loop,offset=$((8192*512)) Armbian_23.11.1_Orangepipc_bookworm_current_6.1.63.img /mnt/orangepipc.img
ls /mnt/orangepipc.img/
```

## boot with qemu

`dtb` & `zImage` files are sitted in `/mnt/orangepipc.img/boot/dtb` and `/mnt/orangepipc.img/boot/zImage` respectively.

In case that simulation is slow, try add append `systemd.default_timeout_start_sec=9000 loglevel=7 nosmp`, referring to official [intro](https://www.qemu.org/docs/master/system/arm/orangepi.html).

```shell
qemu-system-arm \
  -M orangepi-pc \
  -nographic \
  -kernel /mnt/orangepipc.img/boot/zImage -append 'root=/dev/mmcblk0p1' \
  -dtb /mnt/orangepipc.img/boot/dtb/sun8i-h3-orangepi-pc.dtb \
  -sd Armbian_23.11.1_Orangepipc_bookworm_current_6.1.63.img \
  -monitor telnet:127.0.0.1:1234,server,nowait \
  -serial telnet:localhost:4321,server,nowait \
  -device ssd0303,address=0x3c &
  #-append 'systemd.default_timeout_start_sec=9000 loglevel=7 nosmp root=/dev/mmcblk0p1'

# using ctrl-] to escape
sleep 2 && telnet 127.0.0.1 4321
```
