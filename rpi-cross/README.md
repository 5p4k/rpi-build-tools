Raspberry Pi cross-compiling Docker image
=========================================

Debian-based docker image that contains a working toolchain and sysroot to cross-compile
for the Raspberry Pi.

**Note:** this image correctly builds for `armv6`, which is Raspbian's architecture.
Although this appears in Raspbian's package repositories as `armhf`, it actually differs from the `armhf`
from Debian's package repositories.

`sysroot.Dockerfile`
--------------------
This is a Debian based image whose purpose is to pull down the minimal needed packages for compiling, directly from Raspbian's repo.
After build, it contains a fully working (almost minimal) sysroot for Raspbian in `/usr/share/rpi-sysroot`, including CMake files for crosscompiling. **This is intended only as an intermediate to bundle data, not as the cross-compile image.**

Build arguments:
 - `RASPBIAN_VERSION=buster`
   Raspbian version to pull packages from.

The list of packages that constitute a working sysroot is in `_${RASPBIAN_VERSION}/packages.list`, and the extra include paths needed for compilation (which are Raspbian-specific) are in `_${RASPBIAN_VERSION}/RPiStdLib.cmake`.

`debian` and `alpine.Dockerfile`
--------------------------------
These are actual cross-compile images. They use the Clang version shipped with the given Debian or Alpine version as a cross-compiler, and they copy over from `sysroot.Dockerfile` the sysroot data. **These can be used directly for compiling.**

Build arguments:
 - `HOST_IMAGE=alpine:3.11.5` or `debian:buster-slim`
   Version of Alpine or Debian to use as a basis.
 - `HOST_REPO_VERSION=buster`
   (Debian only) version of the repo to pull the compile packages from. This can be used e.g. for backports.
 - `SYSROOT_IMAGE`
   Tag of an image compiled from `sysroot.Dockerfile` to copy the sysroot from. Mandatory.


Helper scripts
==============

Sysroot builder (`scripts/rpi-sysroot.sh`)
------------------------------------------

Creates a Raspbian sysroot by downloading and unpacking the specified packages from the
Raspbian repository. It can also remove files that are not source or libraries.

Usage example:
```
# ./rpi-sysroot.sh --sysroot /usr/share/rpi-sysroot --version buster --package-list _buster/packages.list
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

ELF architecture check (`scripts/arch-check.sh`)
------------------------------------------------
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

General purpose binaries (`bin/`)
---------------------------------
These are bundled into the final image and available in `/usr/bin`.

  - `arch-check`: symlink to `./scripts/arch-check.sh`.
  - `cc-armv6-linux-gnueabihf`: just calls `cc` with the correct Raspberry Pi compile flags:
    `-march=armv6 -mfloat-abi=hard -mfpu=vfp`
  - `cpp-armv6-linux-gnueabihf`: as above, but calls `cpp`.

CMake toolchain (`sysroot/RPi.cmake`)
-------------------------------------
Basic toolchain for cross-compiling. Assumes that a Raspberry Pi sysroot is present
at `/usr/share/rpi-sysroot`, and sets the target triple to `arm-linux-gnueabihf`.
This means that a valid C/C++ compiler for `arm-linux-gnueabihf` must be installed in
the current system (e.g. `cc-` and `cpp-armv6-linux-gnueabihf` wrappers above).
It will also load a list of Raspbian specific include directories (`RASPBIAN_STANDARD_INCLUDE_DIRECTORIES`)
from `/usr/share/rpi-sysroot/RPiStdLib.cmake`.

Sysroot compliance checker (`sysroot/check-armv6`)
--------------------------------------------------
Wrapper for `scripts/arch-check.sh` that analyzes a whole folder.
Called with no arguments will check that the wholesysroot is completely `armv6`-clean.

Usage example:
```
# check-armv6
All the 24 binaries analyzes match the architecture v6.
All the 308 binaries analyzes match the architecture v6.
```
