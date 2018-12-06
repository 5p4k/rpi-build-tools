FROM git-registry.mittelab.org/5p4k/rpi-build-tools/llvm-7-arm
COPY fetch-llvm-src.sh /root/
WORKDIR /root
RUN dpkg --add-architecture armhf \
    && apt-get update \
    && apt-get install -yy --no-install-recommends \
        cmake \
        make \
        unzip \
        curl \
        ca-certificates \
        file \
        python \
        libc6-dev:armhf \
        libgcc-6-dev:armhf \
        libstdc++-6-dev:armhf \
    && /bin/bash fetch-llvm-src.sh -t "" llvm
WORKDIR /root/build
RUN mkdir /root/prefix \
    && LD_FLAGS="-fuse-ld=lld" \
    && TARGET_TRIPLE="arm-linux-gnueabihf" \
    && ARCH_FLAGS="--target=${TARGET_TRIPLE} -march=armv6l -mfloat-abi=hard -mfpu=vfp" \
    && cmake \
        -DCMAKE_CROSSCOMPILING=True \
        -DCMAKE_CXX_FLAGS="${ARCH_FLAGS}" \
        -DCMAKE_C_FLAGS="${ARCH_FLAGS}" \
        -DCMAKE_C_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DCMAKE_CXX_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DCMAKE_ASM_FLAGS="${ARCH_FLAGS}" \
        -DCMAKE_ASM_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DCMAKE_SHARED_LINKER_FLAGS="${LD_FLAGS}" \
        -DCMAKE_MODULE_LINKER_FLAGS="${LD_FLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LD_FLAGS}" \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_INSTALL_PREFIX=/root/prefix \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
        /root/llvm/projects/compiler-rt \
    && make -j$(nproc)
