Dockerfiles for Raspberry Pi cross-compiling
============================================

Scripts
-------
In this subfolders there are scripts that can

 - download LLVM and related projects (clang, ld, libc++, ...)
 - cross-compile libc++ for RPi


`rpi-cross-libcxx.dockerfile`
-----------------------------
**Note: This image is working but it's currently unused**. Libc++ is already included as the packages
in Raspbian, so there is no need to build it.

An extension of `rpi-cross.dockerfile` that cross-compiles its own version of `libc++` and installs it
in the sysroot.

Build options:
 - `RPI_CROSS_IMAGE=git-registry.mittelab.org/5p4k/rpi-build-tools/rpi-cross`  
   this essentially point to a container registry that contains the image `rpi-cross`.
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
 - `LLVM_VERSION=90`
 - `LLVM_TARGETS=ARM`
 - `LLVM_PROJECTS=""`
 - `LLVM_TOOLS="clang lld"`
 - `DEBIAN_IMAGE=debian:buster-slim`
 - `REPO_VERSION=buster`

The latter two options can be used for using the backports, should that be needed,
e.g. before switching to `buster`, the default was to use `DEBIAN_IMAGE=stretch` and
`REPO_VERSION=stretch-backports`.

This image is based on Debian `buster-slim` and will compile using `llvm 7`.