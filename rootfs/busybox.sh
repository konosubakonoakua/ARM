#!/bin/bash

# Set the BusyBox version
BUSYBOX_VERSION=$(curl -L https://www.busybox.net/downloads/ | grep -oP 'busybox-\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n1)
echo ">>>>>>>$BUSYBOX_VERSION"

# Set the cross-compiler prefix for ARM
# CROSS_COMPILE=arm-linux-gnueabi-
CROSS_COMPILE=arm-none-linux-gnueabihf-

# Set the working directory
WORK_DIR=busybox
ROOTFS_DIR="../rootfs"

mkdir -p $WORK_DIR

# Download and extract BusyBox
[ ! -f "$WORK_DIR/busybox-$BUSYBOX_VERSION.tar.bz2" ] && curl -L "https://www.busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2" -o "$WORK_DIR/busybox-$BUSYBOX_VERSION.tar.bz2"
[ ! -d "$WORK_DIR/busybox-$BUSYBOX_VERSION" ] && tar -xf "$WORK_DIR/busybox-$BUSYBOX_VERSION.tar.bz2" -C "$WORK_DIR"

# Enter BusyBox directory
cd "$WORK_DIR/busybox-$BUSYBOX_VERSION"

# Configure BusyBox for cross-compilation and minimal rootfs
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
#sed -i 's/.*CONFIG_FEATURE_SYSLOG=y.*/# CONFIG_FEATURE_SYSLOG is not set/' .config
#sed -i 's/.*CONFIG_FEATURE_MIME_CHARSET.*/# CONFIG_FEATURE_MIME_CHARSET is not set/' .config

# Build BusyBox
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE -j8

# Create a directory for the minimal rootfs
mkdir -p "$ROOTFS_DIR"

# Install BusyBox into the minimal rootfs directory
make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE CONFIG_PREFIX="$ROOTFS_DIR" install
#make ARCH=arm CROSS_COMPILE=$CROSS_COMPILE install

cd "$ROOTFS_DIR"
mkdir -p proc sys dev etc etc/init.d
touch ./etc/init.d/rcS
echo '#!/bin/sh' >./etc/init.d/rcS
echo "mount -t proc none /proc" >>./etc/init.d/rcS
echo "mount -t sysfs none /sys" >>./etc/init.d/rcS
echo "/sbin/mdev -s" >>./etc/init.d/rcS
echo "exec /bin/sh" >>./etc/init.d/rcS
chmod +x etc/init.d/rcS

# Create a cpio archive
find . | cpio -o -H newc >../rootfs.img
cd .. && gzip -9 rootfs.img >"rootfs.img.gz"

echo "Minimal rootfs for ARM created in $ROOTFS_DIR"
echo "Minimal rootfs for ARM packaged into rootfs.img.gz"
echo "Use with qemu: -initrd rootfs.img.gz -append \"root=/dev/ram rdinit=/sbin/init\""
