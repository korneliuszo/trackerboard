

all: shoehorn
#buildroot
.PHONY: shoehorn linux-ram

shoehorn: buildroot-work/stamps/gcc_libs_target_installed
	make -C shoehorn CROSS=../buildroot-work/host/usr/bin/arm-linux-
	mkdir -p output/host/bin
	cp shoehorn/shoehorn output/host/bin
	cp shoehorn/loader.bin output/host/bin

buildroot-work/stamps/gcc_libs_target_installed:
	make -C buildroot O=${PWD}/buildroot-work defconfig BR2_DEFCONFIG=${PWD}/buildroot-config/conf/.defconfig-ram
	make -C buildroot-work toolchain

linux-ram: stamps/linux-ram

stamps/linux-ram: buildroot-config/conf/.defconfig-ram buildroot-config/conf/linux-3.9.config-ram
	make -C buildroot O=${PWD}/buildroot-work defconfig BR2_DEFCONFIG=${PWD}/buildroot-config/conf/.defconfig-ram
	make -C buildroot-work rootfs-cpio
	make -C buildroot-work linux-reconfigure
	mkdir -p output/target/
	cp buildroot-work/images/rootfs.cpio.lzma output/target/rootfs-ram.lzma
	cp buildroot-work/images/zImage output/target/zImage-ram
	touch stamps/linux-ram

COM_PORT ?= "/dev/ttyUSB0"

boot-ram: linux-ram shoehorn
	./output/host/bin/shoehorn --tracker --loader ./output/host/bin/loader.bin --kernel output/target/zImage-ram --initrd output/target/rootfs-ram.lzma --port ${COM_PORT}


