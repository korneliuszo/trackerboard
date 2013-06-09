

all: shoehorn linux-ram linux-rom
#buildroot
.PHONY: shoehorn linux-ram linux-rom

shoehorn: buildroot-work/stamps/gcc_libs_target_installed
	make -C shoehorn CROSS=../buildroot-work/host/usr/bin/arm-linux-
	mkdir -p output/host/bin
	cp shoehorn/shoehorn output/host/bin
	cp shoehorn/loader.bin output/host/bin

buildroot-work/stamps/gcc_libs_target_installed:
	make -C buildroot O=${PWD}/buildroot-work defconfig BR2_DEFCONFIG=${PWD}/buildroot-config/conf/.defconfig-ram
	make -C buildroot-work toolchain

linux-ram: output/target/zImage-ram output/target/rootfs-ram.lzma

output/target/zImage-ram output/target/rootfs-ram.lzma: buildroot-config/conf/.defconfig-ram buildroot-config/conf/linux-3.9.config-ram
	make -C buildroot O=${PWD}/buildroot-work defconfig BR2_DEFCONFIG=${PWD}/buildroot-config/conf/.defconfig-ram
	make -C buildroot-work linux-reconfigure
	make -C buildroot-work all
	mkdir -p output/target/
	cp buildroot-work/images/rootfs.cpio.lzma output/target/rootfs-ram.lzma
	cp buildroot-work/images/zImage output/target/zImage-ram

linux-rom: output/target/zImage-rom output/target/rootfs-rom.lzma

output/target/zImage-rom output/target/rootfs-rom.lzma: buildroot-config/conf/.defconfig-rom buildroot-config/conf/linux-3.9.config-rom
	make -C buildroot O=${PWD}/buildroot-work defconfig BR2_DEFCONFIG=${PWD}/buildroot-config/conf/.defconfig-rom
	make -C buildroot-work linux-reconfigure
	make -C buildroot-work all
	mkdir -p output/target/
	cp buildroot-work/images/rootfs.jffs2 output/target/rootfs-rom.jffs2
	cp buildroot-work/images/zImage output/target/zImage-rom

COM_PORT ?= "/dev/ttyUSB0"

boot-ram: linux-ram shoehorn
	./output/host/bin/shoehorn --tracker --loader ./output/host/bin/loader.bin --kernel output/target/zImage-ram --initrd output/target/rootfs-ram.lzma --port ${COM_PORT}


