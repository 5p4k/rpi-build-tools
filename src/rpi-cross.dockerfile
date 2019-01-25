FROM debian AS builder-sysroot
COPY scripts/rpi-sysroot.sh /root
RUN bash /root/rpi-sysroot.sh --sysroot /root/sysroot


FROM debian:stretch-backports
RUN apt-get -qq update \
    && apt-get install -t stretch-backports -yy --no-install-recommends \
        file \
        binutils \
        clang-6.0 \
        lld-6.0 \
        make \
        cmake
COPY --from=builder-sysroot /root/sysroot /root/sysroot
COPY scripts/arch-check.sh /usr/bin/arch-check
COPY scripts/check-sysroot.sh /root/sysroot/check-armv6
COPY scripts/cpp-armv6-linux-gnueabihf.sh /usr/bin/cpp-armv6-linux-gnueabihf
COPY scripts/cc-armv6-linux-gnueabihf.sh /usr/bin/cc-armv6-linux-gnueabihf
COPY cmake_toolchains/RPiToolchain.cmake /usr/share/
COPY cmake_toolchains/RPiToolchainBase.cmake /usr/share/
RUN chmod +x \
        /usr/bin/arch-check \
        /root/sysroot/check-armv6 \
        /usr/bin/cpp-armv6-linux-gnueabihf \
        /usr/bin/cc-armv6-linux-gnueabihf \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-6.0 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-6.0 100 \
    && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-6.0 100 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/cpp cpp /usr/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/ld ld /usr/bin/lld 100 \
    && /root/sysroot/check-armv6
