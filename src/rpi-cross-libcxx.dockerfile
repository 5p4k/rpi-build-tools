ARG RPI_CROSS_IMAGE=git-registry.mittelab.org/5p4k/rpi-build-tools/rpi-cross
ARG TOOLCHAIN_FILE=/usr/share/RPiToolchain.cmake
ARG SYSROOT=/usr/share/rpi-sysroot
ARG LLVM_VERSION=60


FROM $RPI_CROSS_IMAGE AS builder-libcxx
ARG LLVM_VERSION
ARG TOOLCHAIN_FILE
COPY scripts/cross-build-libcxx.sh scripts/fetch-llvm-src.sh /root/
RUN bash /root/cross-build-libcxx.sh --llvm-version "${LLVM_VERSION}" --toolchain "${TOOLCHAIN_FILE}" --prefix /root/prefix


FROM $RPI_CROSS_IMAGE
ARG SYSROOT
COPY --from=builder-libcxx /root/prefix "$SYSROOT/usr"
COPY cmake_toolchains/RPiStaticLibCxxToolchain.cmake /usr/share/
RUN "${SYSROOT}/check-armv6"
