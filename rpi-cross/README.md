Raspberry Pi cross-compiling Docker image
=========================================

Debian-based docker image that contains a working toolchain and sysroot to cross-compile
for the Raspberry Pi.

**Note:** this image correctly builds for `armv6`, which is Raspbian's architecture.
Although this appears in Raspbian's package repositories as `armhf`, it actually differs from the `armhf`
from Debian's package repositories.

This image uses the default `clang` that comes with Debian (`buster-slim`, currently), and adds on top of it:

 - A Raspberry Pi sysroot, which contains also `libc++`, at `/usr/share/rpi-sysroot`.  
   This is generated with `./scripts/rpi-sysroot.sh` in the current repo.
 - A toolchain for CMake at `/usr/share/rpi-sysroot/RPi.cmake` for cross-compiling. See below.
 - Symlinks for `cpp-armv6-linux-gnueabihf` and `cc-armv6-linux-gnueabihf`, alternatives for `lld`, various build packages (`make`, `cmake`, `binutils`).
 - A couple of helper scripts, `arch-check` and `check-armv6` that help ensuring a binary is `armv6`. See below.

Build options:
 - `RASPBIAN_VERSION=buster`  
   Version of Raspbian to use as a basis for creating the sysroot.
 - `HOST_IMAGE="debian:buster-slim"`  
   Debian image to use as a base for the final image.  
 - `HOST_REPO_VERSION=buster`  
   Version of the repository to use to pull down LLVM and Clang for cross-compiling (in the host).
   This can be used for example to specify backports.

How to use
----------
When running inside the generated image, it suffices to import the CMake toolchain:

```
$ mkdir build_folder
$ cd build_folder
$ cmake -DCMAKE_TOOLCHAIN_FILE=/usr/share/rpi-sysroot/RPi.cmake path/to/my_project
$ make
```

When compiling sources directly, the provided wrappers can be used

```
$ cpp-armv6-linux-gnueabihf my_source_file.cpp
ld: warning: lld uses extended branch encoding, no object with architecture supporting feature detected.
ld: warning: lld may use movt/movw, no object with architecture supporting feature detected.
$ ./a.out   # Will fail because can only run on a Raspberry Pi
/lib/ld-linux-armhf.so.3: No such file or directory  
```


Build helper scripts: (`./scripts`)
===================================

Sysroot builder (`rpi-sysroot.sh`)
----------------------------------

Creates a Raspbian sysroot by downloading and unpacking the specified packages from the
Raspbian repository.

Usage example:
```
# ./rpi-sysroot.sh --sysroot /usr/share/rpi-sysroot --version buster --package-list package_lists/buster.list
>> The script will prepare a sysroot in /usr/share/rpi-sysroot with the following packages:
>>   1. gcc-4.7-base
[...]
>>  15. linux-libc-dev
>> Updating apt...
apt-get -qq update
>> Installing gnupg2 and dirmngr...
apt-get install -qq -yy --no-install-recommends gnupg2 dirmngr
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package readline-common.
(Reading database ... 6457 files and directories currently installed.)
[...]
>> Importing Raspbian key...
apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E
Warning: apt-key output should not be parsed (stdout is not a terminal)
Executing: /tmp/apt-key-gpghome.q411doaq67/gpg.1.sh --no-tty --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E
gpg: key 9165938D90FDDD2E: public key "[...]" imported
gpg: Total number processed: 1
gpg:               imported: 1
>> Updating apt for Raspbian packages...
dpkg --add-architecture armhf
apt-get -qq update
>> Downloading all packages. Ignore errors about owner of the folder...
/tmp/tmp.Jf3d7H4qhc /
apt-get download -qq gcc-4.7-base:armhf libc++-dev:armhf libc++1:armhf libc++abi-dev:armhf libc++abi1:armhf libc-bin:armhf libc-dev-bin:armhf libc6:armhf libc6-dev:armhf libgcc-4.7-dev:armhf libgcc1:armhf libgomp1:armhf libstdc++6:armhf libstdc++6-4.7-dev:armhf linux-libc-dev:armhf
W: Download is performed unsandboxed as root as file '/tmp/tmp.Jf3d7H4qhc/gcc-4.7-base_4.7.3-11+rpi1_armhf.deb' couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
/
>> Restoring previous apt cache.
dpkg --remove-architecture armhf
apt-get -qq update
>> Listing all downloaded packages:
/tmp/tmp.Jf3d7H4qhc/libc++-dev_3.5-2_armhf.deb
[...]
/tmp/tmp.Jf3d7H4qhc/libc6_2.24-11+deb9u4_armhf.deb
>> Extracting all packages to /usr/share/rpi-sysroot...
dpkg-deb --extract /tmp/tmp.Jf3d7H4qhc/libc++-dev_3.5-2_armhf.deb /usr/share/rpi-sysroot
[...]
dpkg-deb --extract /tmp/tmp.Jf3d7H4qhc/libc6_2.24-11+deb9u4_armhf.deb /usr/share/rpi-sysroot
>> Completed, removing package files.
```

ELF architecture check (`arch-check.sh`)
----------------------------------------
Analyzes the architecture of the specified binaries, optionally ensures that all
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

Bundled scripts/toolchains
==========================

General purpose binaries (`./bin`)
----------------------------------
These are bundled into the final image and available in `/usr/bin`.

  - `arch-check`: symlink to `./scripts/arch-check.sh`.  
  - `cc-armv6-linux-gnueabihf`: just calls `cc` with the correct Raspberry Pi compile flags:  
    `-march=armv6 -mfloat-abi=hard -mfpu=vfp`
  - `cpp-armv6-linux-gnueabihf`: as above, but calls `cpp`.

CMake toolchain (`./sysroot/RPi.cmake`)
--------------------------------------
Basic toolchain for cross-compiling. Assumes that a Raspberry Pi sysroot is present
at `/usr/share/rpi-sysroot`, and sets the target triple to `arm-linux-gnueabihf`.
This means that a valid C/C++ compiler for `arm-linux-gnueabihf` must be installed in
the current system (e.g. `cc-` and `cpp-armv6-linux-gnueabihf` wrappers above).  

Sysroot compliance checker (`./sysroot/check-armv6`)
----------------------------------------------------
Wrapper for `./scripts/arch-check.sh` that analyzes a whole folder.
Called with no arguments will check that the wholesysroot is completely `armv6`-clean.

Usage example:
```
# check-armv6
All the 24 binaries analyzes match the architecture v6.
All the 308 binaries analyzes match the architecture v6.
```
