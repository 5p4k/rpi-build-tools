RPi Build Tools (unofficial)
============================

**Official repo:** [https://git.mittelab.org/5p4k/rpi-build-tools][repo_url]  
**Build status:** [![pipeline status][pipeline_svg]][pipeline]
**Docker Hub:** [https://hub.docker.com/repository/docker/5p4k/rpi-cross][hub_url]

Unofficial helper scripts and Docker images to cross-compile for the Raspberry Pi (in `armv6`).
Binaries compiled with this image can be directly copied to the Raspberry Pi.

Image usage
-----------
The image provides
 - `/usr/share/rpi-sysroot/RPi.cmake`  
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
  
When running inside the generated image, it suffices to import the CMake toolchain:

```
$ docker run -it --rm -v /path/to/project:/mnt 5p4k/rpi-cross:buster
# mkdir build_folder
# cd build_folder
# cmake -DCMAKE_TOOLCHAIN_FILE=/usr/share/rpi-sysroot/RPi.cmake ..
# make
# exit
```

When compiling sources directly, the provided wrappers can be used

```
$ docker run -it --rm -v /path/to/project:/mnt rpi-cross:buster
# cpp-armv6-linux-gnueabihf my_source_file.cpp
ld: warning: lld uses extended branch encoding, no object with architecture supporting feature detected.
ld: warning: lld may use movt/movw, no object with architecture supporting feature detected.
# ./a.out   # Will fail because can only run on a Raspberry Pi
/lib/ld-linux-armhf.so.3: No such file or directory  
# exit
```

[repo_url]: https://git.mittelab.org/5p4k/rpi-build-tools
[pipeline]: https://git.mittelab.org/5p4k/rpi-build-tools/commits/master
[pipeline_svg]: https://git.mittelab.org/5p4k/rpi-build-tools/badges/master/pipeline.svg
[hub_url]: https://hub.docker.com/repository/docker/5p4k/rpi-cross
