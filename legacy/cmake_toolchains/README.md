Toolchains for CMake cross-compilation
======================================

`RPiLibCxx.cmake`
-----------------
If `libc++` is installed in the sysroot, it can be used instead of `libstdc++` as
a standard C++ library. This toolchain imports `RPi.cmake` and extends it by selecting
`libc++` instead of the standard C++ library.

`RpiStaticLibCxx.cmake`
-----------------------
As `RpiLibCxx.cmake`, but statically links against `libc++`.
