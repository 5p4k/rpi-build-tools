ARG HOST_IMAGE=debian:buster-slim
ARG HOST_REPO_VERSION=buster
ARG RASPBIAN_VERSION=buster

FROM debian:buster-slim AS builder-sysroot
ARG RASPBIAN_VERSION
COPY "shared/scripts/rpi-sysroot.sh" "/root"
COPY "_${RASPBIAN_VERSION}/packages.list" "/root/packages.list"
RUN bash \
    /root/rpi-sysroot.sh \
        --version "${RASPBIAN_VERSION}" \
        --sysroot "/usr/share/rpi-sysroot" \
        --package-list "/root/packages.list"

FROM $HOST_IMAGE
ARG HOST_REPO_VERSION
ARG RASPBIAN_VERSION
RUN apt-get -qq update \
    && apt-get install -t "${HOST_REPO_VERSION}" -yy --no-install-recommends \
        file \
        binutils \
        clang-7 \
        lld-7 \
        make \
        llvm-7-dev \
        cmake
COPY --from=builder-sysroot "/usr/share/rpi-sysroot" "/usr/share/rpi-sysroot"
COPY "shared/bin/*"                   "/usr/bin/"
COPY "shared/sysroot/*"               "/usr/share/rpi-sysroot/"
COPY "_${RASPBIAN_VERSION}/sysroot/*" "/usr/share/rpi-sysroot/"
RUN    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-7 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-7 100 \
    && update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-7 100 \
    && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-7 100 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/cpp cpp /usr/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/ld ld /usr/bin/lld 100 \
    && /usr/share/rpi-sysroot/check-armv6
