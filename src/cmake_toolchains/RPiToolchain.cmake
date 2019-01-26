set(TARGET_TRIPLE       "arm-linux-gnueabihf")
set(TARGET_SYSROOT      "/usr/share/rpi-sysroot")
set(TARGET_ARCH_FLAGS   "--target=${TARGET_TRIPLE} -march=armv6 -mfloat-abi=hard -mfpu=vfp --sysroot ${TARGET_SYSROOT}")
set(TARGET_LINKER_FLAGS "-fuse-ld=lld --sysroot ${TARGET_SYSROOT}")

# Setting the system name enables CMAKE_CROSSCOMPILING
set(CMAKE_SYSTEM_NAME               "Linux")

# System root
set(CMAKE_SYSROOT                   "${TARGET_SYSROOT}")

# Explicitly set the targets for all the compilers
set(CMAKE_C_COMPILER_TARGET         "${TARGET_TRIPLE}")
set(CMAKE_CXX_COMPILER_TARGET       "${TARGET_TRIPLE}")

# Add the target architecture flags to all the compilers
set(CMAKE_C_FLAGS_INIT              "${TARGET_ARCH_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT            "${TARGET_ARCH_FLAGS}")

# This is needed otherwise the compiler identification is unknown
string(PREPEND CMAKE_C_FLAGS        "${CMAKE_C_FLAGS_INIT} ")   # Ends with space
string(PREPEND CMAKE_CXX_FLAGS      "${CMAKE_CXX_FLAGS_INIT} ") # Ends with space

# This configuration is specific to the Docker image
# Ensure clang is the chosen compiler and lld the linker
set(CMAKE_C_COMPILER                "clang")
set(CMAKE_CXX_COMPILER              "clang++")
set(CMAKE_SHARED_LINKER_FLAGS_INIT  "${TARGET_LINKER_FLAGS}")
set(CMAKE_STATIC_LINKER_FLAGS_INIT  "${TARGET_LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT  "${TARGET_LINKER_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT     "${TARGET_LINKER_FLAGS}")

# Ensure find_* operations are correct
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
