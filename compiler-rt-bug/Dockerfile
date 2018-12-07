FROM debian:stretch
WORKDIR /root
RUN dpkg --add-architecture armhf \
    && apt-get update \
    && apt-get install -yy --no-install-recommends \
        unzip \
        curl \
        ca-certificates \
    && for PROJ_TOOL in llvm compiler-rt; do \
        export PROJ_TOOL_URL="https://github.com/llvm-mirror/${PROJ_TOOL}/archive/release_70.zip"; \
        curl -L -o "${PROJ_TOOL}.zip" "${PROJ_TOOL_URL}"; \
        unzip -q "${PROJ_TOOL}.zip"; \
        rm "${PROJ_TOOL}.zip"; \
        mv "${PROJ_TOOL}-release_70" "${PROJ_TOOL}"; \
    done \
    && mv compiler-rt llvm/projects
RUN apt-get install -yy --no-install-recommends \
        cmake \
        make \
        python \
        libc6-dev:armhf \
        libgcc-6-dev:armhf \
        libstdc++-6-dev:armhf \
        clang-4.0 \
        lld-4.0
WORKDIR /root/build
RUN TARGET_TRIPLE="arm-linux-gnueabihf" \
    && ARCH_FLAGS="--target=${TARGET_TRIPLE} -march=armv6 -mfloat-abi=hard -mfpu=vfp" \
    && LD_FLAGS="-fuse-ld=lld" \
    && cmake \
        -DCMAKE_CROSSCOMPILING=True \
        -DCMAKE_C_COMPILER=clang-4.0 \
        -DCMAKE_CXX_COMPILER=clang++-4.0 \
        -DCMAKE_ASM_COMPILER=clang-4.0 \
        -DLLVM_CONFIG_PATH=$(which llvm-config-4.0) \
        -DCMAKE_CXX_FLAGS="${ARCH_FLAGS}" \
        -DCMAKE_C_FLAGS="${ARCH_FLAGS}" \
        -DCMAKE_C_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DCMAKE_CXX_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DCMAKE_ASM_FLAGS="${ARCH_FLAGS}" \
        -DCMAKE_ASM_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DCMAKE_SHARED_LINKER_FLAGS="${LD_FLAGS}" \
        -DCMAKE_MODULE_LINKER_FLAGS="${LD_FLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LD_FLAGS}" \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
        /root/llvm/projects/compiler-rt
RUN make builtins
RUN make
