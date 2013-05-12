

all: shoehorn buildroot
.PHONY: shoehorn buildroot-toolchain buildroot

shoehorn: buildroot-toolchain
	make -C shoehorn CROSS=../buildroot/output/host/usr/bin/arm-linux-

buildroot-toolchain:
	make -C buildroot toolchain

buildroot:
	make -C buildroot all
