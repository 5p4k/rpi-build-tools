Toolchains for CMake cross-compilation
======================================
Note that the CMake files here reference one another, so they should all be present.
They also assume that a Raspberry Pi sysroot is present at `/usr/share/rpi-sysroot`.

`RPi.cmake`
-----------
Basic toolchain for cross-compiling. Assumes that a Raspberry Pi sysroot is present
at `/usr/share/rpi-sysroot`, and sets the target triple to `arm-linux-gnueabihf`.
This means that a valid C/C++ compiler for `arm-linux-gnueabihf` must be installed in
the current system.
One such sysroot can be created using the `src/scripts/rpi-sysroot.sh` script in the
current repository. Cross-compilers for the current system must be build on purpose.

`RPiLibCxx.cmake`
-----------------
If `libc++` is installed in the sysroot, it can be used instead of `libstdc++` as
a standard C++ library. This toolchain imports `RPi.cmake` and extends it by selecting
`libc++` instead of the standard C++ library.

`RpiStaticLibCxx.cmake`
-----------------------
As `RpiLibCxx.cmake`, but statically links against `libc++`.