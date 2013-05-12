#!/bin/bash

for i in output/build/linux-*
do
cp $i/.config ../buildroot-config/conf/`basename $i`.config
done

for i in output/build/busybox-*
do
cp $i/.config ../buildroot-config/conf/`basename $i`.config
done

