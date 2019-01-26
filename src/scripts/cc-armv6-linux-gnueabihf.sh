#!/bin/sh
cc --target=arm-linux-gnueabihf -march=armv6 -mfloat-abi=hard -mfpu=vfp --sysroot /usr/share/rpi-sysroot -fuse-ld=lld "$@"