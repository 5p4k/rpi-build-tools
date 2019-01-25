ARG BASE_BUILDER_IMAGE=git-registry.mittelab.org/5p4k/rpi-build-tools/llvm6-arm

FROM debian:stretch-backports AS builder-sysroot
COPY etc/cross-armv6-sources.list /root
WORKDIR /root
RUN apt-get -qq update \
    && apt-get install -yy --no-install-recommends \
        gnupg2 \
        dirmngr \
    && apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E
RUN mv /root/cross-armv6-sources.list /etc/apt/sources.list \
    && dpkg --add-architecture armhf \
    && apt-get update \
    && mkdir packages \
    && mkdir sysroot
WORKDIR /root/packages
RUN apt-get download \
        gcc-4.7-base:armhf \
        libc-bin:armhf \
        libc-dev-bin:armhf \
        libc6-dev:armhf \
        libc6:armhf \
        libgcc-4.7-dev:armhf \
        libgcc1:armhf \
        libgomp1:armhf \
        libstdc++6-4.7-dev:armhf \
        libstdc++6:armhf \
        linux-libc-dev:armhf
RUN for PKG in *.deb; do \
            dpkg-deb --extract "${PKG}" /root/sysroot; \
        done


FROM $BASE_BUILDER_IMAGE
RUN apt-get -qq update \
    && apt-get install -yy --no-install-recommends \
        file \
        binutils
COPY --from=builder-sysroot /root/sysroot /root/sysroot
COPY scripts/arch-check.sh /usr/bin/arch-check
COPY scripts/check-sysroot.sh /root/sysroot/check
RUN chmod +x /usr/bin/arch-check \
    && chmod +x /root/sysroot/check \
    && /root/sysroot/check
