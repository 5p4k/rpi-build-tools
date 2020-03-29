set(TARGET_TRIPLE             "arm-linux-gnueabihf")
set(TARGET_SYSROOT            "/usr/share/rpi-sysroot")
set(TARGET_ARCH_FLAGS         "--target=${TARGET_TRIPLE} -march=armv6 -mfloat-abi=hard -mfpu=vfp")

set(CMAKE_CROSSCOMPILING      "True")

# System root
set(CMAKE_SYSROOT             "${TARGET_SYSROOT}")

# Explicitly set the targets for all the compilers
set(CMAKE_C_COMPILER_TARGET   "${TARGET_TRIPLE}")
set(CMAKE_CXX_COMPILER_TARGET "${TARGET_TRIPLE}")

# Add the target architecture flags to all the compilers
set(CMAKE_C_FLAGS_INIT        "${TARGET_ARCH_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT      "${TARGET_ARCH_FLAGS}")
