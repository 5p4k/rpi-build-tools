set(CMAKE_CROSSCOMPILING "True")
set(CMAKE_SYSROOT "/usr/share/rpi-sysroot")
set(TARGET_TRIPLE "arm-linux-gnueabihf")

# Will populate RASPBIAN_STANDARD_INCLUDE_DIRECTORIES
include("${CMAKE_SYSROOT}/RPiStdLib.cmake")

foreach(LANG  C CXX)
    # Explicitly set the targets for all the compilers
    set(CMAKE_${LANG}_COMPILER_TARGET "${TARGET_TRIPLE}")

    # Add the target architecture flags to all the compilers
    set(CMAKE_${LANG}_FLAGS_INIT "--target=${TARGET_TRIPLE} -march=armv6 -mfloat-abi=hard -mfpu=vfp")

    # Add the directories specific to the current Raspbian install
    set(CMAKE_${LANG}_STANDARD_INCLUDE_DIRECTORIES ${RASPBIAN_STANDARD_INCLUDE_DIRECTORIES})
endforeach()

# Change the linker to LLD (we need a linker for a different target)
# Static linker is actually "ar", so no need to set that for STATIC too
foreach(TARGET EXE MODULE SHARED)
    set(CMAKE_${TARGET}_LINKER_FLAGS_INIT "-fuse-ld=lld")
endforeach()
