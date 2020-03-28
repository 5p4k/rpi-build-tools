Dockerfiles for Raspberry Pi cross-compiling
============================================

Scripts
-------
In this subfolders there are scripts that can
 - create a whole Raspberry Pi sysroot from scratch
 - download LLVM
 - cross-compile libc++ for RPi
 - check the architecture of a sysroot

`llvm.dockerfile`
-----------------
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