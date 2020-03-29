Dockerfiles for Raspberry Pi cross-compiling
============================================

`rpi-cross.dockerfile`
----------------------
Debian-based docker image that contains a working toolchain and sysroot to cross-compile
for the Raspberry Pi. This uses the default `clang` that comes with Debian (`buster-slim`,
currently), and adds on top of it

 - a Raspberry Pi sysroot, which contains also `libc++`, at `/usr/share/rpi-sysroot`; this is generated with `src/scripts/rpi-sysroot.sh` in the current repo.
 - a toolchain for CMake `/usr/share/RPi.cmake` for cross-compiling; this comes from `src/cmake_toolchains/RPi.cmake`;
 - symlinks for `cpp-armv6-linux-gnueabihf` and `cc-armv6-linux-gnueabihf`, alternatives for `lld`, various build packages (`make`, `cmake`, `binutils`);
 - a couple of helper scripts, `arch-check` and `check-armv7` (which are `src/scripts/check-sysroot.sh` and `src/scripts/arch-check.sh` in the current repository) that help ensuring a binary is `armv6`.
 
This is ready to crosscompile.

Build options:
 - `DEBIAN_IMAGE="debian:buster-slim"`  
   Debian image to use as a base for the final image.
 - `REPO_VERSION=buster`  
   Version of the repository to use to pull down LLVM and clang for cross-compiling (in the final image).
   This can be used for example to specify backports.
 - `RASPBIAN_VERSION=buster`
   Version of Raspbian to use as a basis for creating the sysroot

Scripts
-------
In this subfolders there are scripts that can

 - create a whole Raspberry Pi sysroot from scratch
 - download LLVM and related projects (clang, ld, libc++, ...)
 - cross-compile libc++ for RPi
 - check the architecture of a sysroot

CMake toolchain: `./sysroot/RPi.cmake`
--------------------------------------
Basic toolchain for cross-compiling. Assumes that a Raspberry Pi sysroot is present
at `/usr/share/rpi-sysroot`, and sets the target triple to `arm-linux-gnueabihf`.
This means that a valid C/C++ compiler for `arm-linux-gnueabihf` must be installed in
the current system.  
One such sysroot can be created using the `./scripts/rpi-sysroot.sh` script in the
current repository.

Raspberry build scripts
=======================

`rpi-sysroot.sh`
----------------

Creates a Raspbian Sysroot by downloading and unpacking the specified packages from the
Raspbian repository. By default, only downloads packages essentials to build other software, plus extra
`libc++`. Here's the current list of packages bundled in the sysroot:

 - `gcc-8-base`
 - `libc-bin`
 - `libc-dev-bin`
 - `libc6-dev`
 - `libc6`
 - `libgcc-8-dev`
 - `libgcc1`
 - `libgomp1`
 - `libstdc++-8-dev`
 - `libstdc++6`
 - `linux-libc-dev`
 - `libc++-8-dev`
 - `libc++1-8`
 - `libc++abi-8-dev`
 - `libc++abi1-8`

Usage example:
```
# ./rpi-sysroot.sh --sysroot /usr/share/rpi-sysroot --version buster
>> The script will prepare a sysroot in /usr/share/rpi-sysroot with the following packages:
>>   1. gcc-8-base
>>   2. libc-bin
>>   3. libc-dev-bin
>>   4. libc6
>>   5. libc6-dev
>>   6. libgcc-8-dev
>>   7. libgcc1
>>   8. libgomp1
>>   9. libstdc++-8-dev
>>  10. libstdc++6
>>  11. linux-libc-dev
>> Updating apt...
apt-get -qq update
>> Installing gnupg2 and dirmngr...
apt-get install -qq -yy --no-install-recommends gnupg2 dirmngr
[...]
>> Importing Raspbian key...
apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E
Executing: /tmp/apt-key-gpghome.inzrPJ2WfO/gpg.1.sh --no-tty --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E
gpg: key 9165938D90FDDD2E: public key "Mike Thompson (Raspberry Pi Debian armhf ARMv6+VFP) <mpthompson@gmail.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
>> Updating apt for Raspbian packages...
dpkg --add-architecture armhf
apt-get -qq update
>> Downloading all packages. Ignore errors about owner of the folder...
/tmp/tmp.ZQcoDReQeq /mnt/src/scripts
apt-get download -qq gcc-8-base:armhf libc-bin:armhf libc-dev-bin:armhf libc6:armhf libc6-dev:armhf libgcc-8-dev:armhf libgcc1:armhf libgomp1:armhf libstdc++-8-dev:armhf libstdc++6:armhf linux-libc-dev:armhf
W: Download is performed unsandboxed as root as file '/tmp/tmp.ZQcoDReQeq/gcc-8-base_8.3.0-6+rpi1_armhf.deb' couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
/mnt/src/scripts
>> Restoring previous apt cache.
dpkg --remove-architecture armhf
apt-get -qq update
>> Listing all downloaded packages:
/tmp/tmp.ZQcoDReQeq/libgomp1_8.3.0-6+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/libstdc++6_8.3.0-6+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/libc6_2.28-10+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/libgcc-8-dev_8.3.0-6+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/libgcc1_1%3a8.3.0-6+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/gcc-8-base_8.3.0-6+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/libc6-dev_2.28-10+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/libstdc++-8-dev_8.3.0-6+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/libc-dev-bin_2.28-10+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/linux-libc-dev_4.18.20-2+rpi1_armhf.deb
/tmp/tmp.ZQcoDReQeq/libc-bin_2.28-10+rpi1_armhf.deb
>> Extracting all packages to /usr/share/rpi-sysroot...
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libgomp1_8.3.0-6+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libstdc++6_8.3.0-6+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libc6_2.28-10+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libgcc-8-dev_8.3.0-6+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libgcc1_1%3a8.3.0-6+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/gcc-8-base_8.3.0-6+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libc6-dev_2.28-10+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libstdc++-8-dev_8.3.0-6+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libc-dev-bin_2.28-10+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/linux-libc-dev_4.18.20-2+rpi1_armhf.deb /usr/share/rpi-sysroot
dpkg-deb --extract /tmp/tmp.ZQcoDReQeq/libc-bin_2.28-10+rpi1_armhf.deb /usr/share/rpi-sysroot
>> Completed, removing package files.
```

`arch-check.sh`
---------------
Requires `file` and `readelf` to be installed (`apt install file binutils`).
Analyzed the architecture of the specified binaries, optionally ensures that all
match a given architecture. This can be used to make sure that compiled binaries
are correctly on `armv6`.

Usage example:
```
# ./arch-check.sh --ensure v6 /usr/share/rpi-sysroot/usr/bin/*
/usr/share/rpi-sysroot/usr/bin/gencat: v6
/usr/share/rpi-sysroot/usr/bin/getconf: v6
/usr/share/rpi-sysroot/usr/bin/getent: v6
/usr/share/rpi-sysroot/usr/bin/iconv: v6
/usr/share/rpi-sysroot/usr/bin/locale: v6
/usr/share/rpi-sysroot/usr/bin/localedef: v6
/usr/share/rpi-sysroot/usr/bin/pldd: v6
/usr/share/rpi-sysroot/usr/bin/rpcgen: v6
/usr/share/rpi-sysroot/usr/bin/sprof: v6
/usr/share/rpi-sysroot/usr/bin/zdump: v6
All the 10 binaries analyzes match the architecture v6.
```

`check-sysroot.sh`
------------------
Wrapper for `arch-check.sh` that analyzes a whole folder. Can be used to check that
the whole sysroot is completely `armv6`-clean.

Usage example:
```
# ./check-sysroot.sh /usr/share/rpi-sysroot/
All the 24 binaries analyzes match the architecture v6.
All the 308 binaries analyzes match the architecture v6.
```

`cc|cpp-armv6-linux-gnueabihf.sh`
---------------------------------
One-line wrappers for `cc` and `c++` which add the following options:
`--target=arm-linux-gnueabihf -march=armv6 -mfloat-abi=hard -mfpu=vfp --sysroot /usr/share/rpi-sysroot`