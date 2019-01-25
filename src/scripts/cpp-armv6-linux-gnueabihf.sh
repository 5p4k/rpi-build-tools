#!/bin/sh
c++ --target=arm-linux-gnueabihf -march=armv6 -mfloat-abi=hard -mfpu=vfp --sysroot /root/sysroot -fuse-ld=lld "$@"