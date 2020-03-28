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

CMake toolchains
----------------
In this subfolders there are pre-made CMake files that enable
crosscompiling for the Raspberry Pi.


`rpi-cross-libcxx.dockerfile`
-----------------------------
**Note: This image is working but it's currently unused**. Libc++ is already included as the packages
in Raspbian, so there is no need to build it.

An extension of `rpi-cross.dockerfile` that cross-compiles its own version of `libc++` and installs it
in the sysroot.

Build options:
 - `RPI_CROSS_IMAGE=git-registry.mittelab.org/5p4k/rpi-build-tools/rpi-cross`  
   this essentially point to a container registry that contains the image `rpi-cross` as above.
 - `TOOLCHAIN_FILE=/usr/share/RPi.cmake`  
   this is just `src/cmake_toolchains/RPi.cmake` in the current repo.
 - `SYSROOT=/usr/share/rpi-sysroot`
   the sysroot extracted with `src/scripts/rpi-sysroot.sh`
 - `LLVM_VERSION=90`



`llvm.dockerfile`
-----------------
**Note: This image is working but it's currently unused**. ARM is already a
target in the default install in Debian, so there is no need to rebuild it
from scratch.

A Debian-based dockerfile image that builds LLVM from scratch.
By default, it builds it only with the `ARM` target, for cross-compiling.

Although one can build the whole LLVM toolchain, this image builds only
`clang` and `lld`. Stuff like `compiler-rt` is left out because at the
moment [cannot be used on ARMv6](https://bugs.llvm.org/show_bug.cgi?id=39906).

The build options:
 - `LLVM_VERSION = 90`
 - `LLVM_TARGETS = ARM`
 - `LLVM_PROJECTS = ""`
 - `LLVM_TOOLS = "clang lld"`
 - `DEBIAN_IMAGE=debian:buster-slim`
 - `REPO_VERSION=buster`

The latter two options can be used for using the backports, should that be needed,
e.g. before switching to `buster`, the default was to use `DEBIAN_IMAGE=stretch` and
`REPO_VERSION=stretch-backports`.

This image is based on Debian `buster-slim` and will compile using `llvm 7`.