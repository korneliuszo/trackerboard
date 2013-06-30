

all: shoehorn linux-ram linux-rom
#buildroot
.PHONY: shoehorn linux-ram linux-rom

shoehorn: tracker-ram/stamps/gcc_libs_target_installed
	make -C shoehorn CROSS=../tracker-ram/host/usr/bin/arm-linux-
	mkdir -p output/host/bin
	cp shoehorn/shoehorn output/host/bin
	cp shoehorn/loader.bin output/host/bin

tracker-ram/stamps/gcc_libs_target_installed:
	make -C buildroot O=${PWD}/tracker-ram defconfig BR2_DEFCONFIG=${PWD}/buildroot-config/conf/.defconfig-ram
	make -C tracker-ram toolchain

linux-ram: output/target/zImage-ram output/target/rootfs-ram.lzma

output/target/zImage-ram output/target/rootfs-ram.lzma: buildroot-config/conf/.defconfig-ram tracker-ram/Makefile
	make -C tracker-ram linux-reconfigure
	make -C tracker-ram all
	mkdir -p output/target/
	cp tracker-ram/images/rootfs.cpio.lzma output/target/rootfs-ram.lzma
	cp tracker-ram/images/zImage output/target/zImage-ram

tracker-ram/Makefile: buildroot-config/conf/linux-3.9.config-ram
	make -C buildroot O=${PWD}/tracker-ram defconfig BR2_DEFCONFIG=${PWD}/buildroot-config/conf/.defconfig-ram

linux-rom: output/target/zImage-rom output/target/rootfs-rom.jffs2

output/target/zImage-rom output/target/rootfs-rom.jffs2: buildroot-config/conf/.defconfig-rom tracker-rom/Makefile
	make -C tracker-rom linux-reconfigure
	make -C tracker-rom all
	mkdir -p output/target/
	cp tracker-rom/images/rootfs.jffs2 output/target/rootfs-rom.jffs2
	cp tracker-rom/images/zImage output/target/zImage-rom

tracker-rom/Makefile: buildroot-config/conf/linux-3.9.config-rom
	make -C buildroot O=${PWD}/tracker-rom defconfig BR2_DEFCONFIG=${PWD}/buildroot-config/conf/.defconfig-rom


COM_PORT ?= "/dev/ttyUSB0"

boot-ram: linux-ram shoehorn
	./output/host/bin/shoehorn --tracker --loader ./output/host/bin/loader.bin --kernel output/target/zImage-ram --initrd output/target/rootfs-ram.lzma --port ${COM_PORT}


