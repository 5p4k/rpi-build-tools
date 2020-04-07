Raspberry Pi cross-compile images (unofficial)
==============================================
**Official repo:** [https://git.mittelab.org/5p4k/rpi-build-tools][repo_url]
[![pipeline status][pipeline_svg]][pipeline]

A set of x86_64 (no need for QEMU) images with the basic compiling tools and a minimal sysroot for Raspbian, to cross-compile for the Raspberry Pi (in `armv6`, so runs also on the RPi 1). Binaries compiled with this image can be directly copied to the Raspberry Pi. **The sysroot for Raspbian is generated directly by extracting the essential `.deb` packages from Raspbian, to keep it as small as possible.** Unneeded files such as executables are removed from the sysroot.

 - `latest`, `buster`, `buster-on-alpine`
   Alpine-based (`3.11.5`, Clang 9) cross-compile image for Raspbian Buster (~80MB)
 - `stretch`, `stretch-on-alpine`
   Alpine-based (`3.11.5`, Clang 9) cross-compile image for Raspbian Stretch (~80MB)
 - `buster-on-debian`
   Debian-based (`buster-slim`, Clang 7) cross-compile image for Raspbian Buster (~200MB)
 - `stretch-on-debian`
   Debian-based (`buster-slim`, Clang 7) cross-compile image for Raspbian Stretch (~200MB)

---

Images come in two flavours:
 - **[Alpine](https://hub.docker.com/_/alpine) based, currently `3.11.5`**
   Currently the smaller image (~80MB), cross-compiles using the shipped Clang 9.
 - **[Debian](https://hub.docker.com/_/debian) based, currently `buster-slim`**
   Currently ~200MB, cross-compiles using the shipped Clang 7.

Choose the image tag based on the version of Raspbian you're compiling *for*:
 - `docker pull 5p4k/rpi-cross:buster`
 - `docker pull 5p4k/rpi-cross:stretch`

Usage with CMake
---
Specify `-DCMAKE_TOOLCHAIN_FILE=/usr/share/RPi.cmake` when calling CMake.

```
$ docker run -it --rm -v /path/to/project:/mnt 5p4k/rpi-cross:buster
# cd /mnt
# mkdir build_folder
# cd build_folder
# cmake -DCMAKE_TOOLCHAIN_FILE=/usr/share/rpi-sysroot/RPi.cmake ..
# make
# exit
```

Usage when compiling directly
---
Use the wrappers `cc-` and `cpp-armv6-linux-gnueabihf` instead of `cc` and `c++`.

```
$ docker run -it --rm -v /path/to/project:/mnt 5p4k/rpi-cross:buster
# cd /mnt
# cpp-armv6-linux-gnueabihf my_source_file.cpp
ld: warning: lld uses extended branch encoding, no object with architecture supporting feature detected.
ld: warning: lld may use movt/movw, no object with architecture supporting feature detected.
# ./a.out   # Will fail because can only run on a Raspberry Pi
/lib/ld-linux-armhf.so.3: No such file or directory
# exit
```

What's in the image
---

 - `/usr/share/RPi.cmake`
   CMake toolchain for cross-compilation.
 - `/usr/share/rpi-sysroot`
   Sysroot from RPi cross-compilation.
 - `/usr/share/rpi-sysroot/check-armv6`
   Checks that the sysroot contains only `armv6` binaries.
 - `/usr/bin/cc-armv6-linux-gnueabihf`
   Cross-compile wrapper for the C compiler.
 - `/usr/bin/cpp-armv6-linux-gnueabihf`
   Cross-compile wrapper for the C++ compiler.
 - `/usr/bin/arch-check`
   Checks the architecture of a binary.

Packages in the sysroot
---
**Buster:** `gcc-8-base`, `libc-bin`, `libc-dev-bin`, `libc6-dev`, `libc6`, `libgcc-8-dev`, `libgcc1`, `libgomp1`, `libstdc++-8-dev`, `libstdc++6`, `linux-libc-dev`, `libc++-8-dev`, `libc++1-8`, `libc++abi-8-dev`, `libc++abi1-8`

**Stretch:** `gcc-4.7-base`, `libc-bin`, `libc-dev-bin`, `libc6-dev`, `libc6`, `libgcc-4.7-dev`, `libgcc1`, `libgomp1`, `libstdc++6-4.7-dev`, `libstdc++6`, `linux-libc-dev`, `libc++1`, `libc++-dev`, `libc++abi1`, `libc++abi-dev`


[repo_url]: https://git.mittelab.org/5p4k/rpi-build-tools
[pipeline]: https://git.mittelab.org/5p4k/rpi-build-tools/commits/master
[pipeline_svg]: https://git.mittelab.org/5p4k/rpi-build-tools/badges/master/pipeline.svg

