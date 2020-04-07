ARG HOST_IMAGE=debian:buster-slim
ARG HOST_REPO_VERSION=buster
ARG SYSROOT_IMAGE

FROM ${SYSROOT_IMAGE} as sysroot

FROM $HOST_IMAGE
ARG HOST_REPO_VERSION
RUN apt-get -qq update \
    && apt-get install -t "${HOST_REPO_VERSION}" -yy --no-install-recommends \
        file \
        clang-7 \
        lld-7 \
        make \
        llvm-7-dev \
        cmake
COPY --from=sysroot "/usr/share/rpi-sysroot" "/usr/share/rpi-sysroot"
COPY "bin/*" "/usr/bin/"
RUN    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-7 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-7 100 \
    && update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-7 100 \
    && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-7 100 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/cpp cpp /usr/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/ld ld /usr/bin/lld 100 \
    && ln -s "/usr/share/rpi-sysroot/RPi.cmake" "/usr/share/RPi.cmake" \
    && /usr/share/rpi-sysroot/check-armv6
