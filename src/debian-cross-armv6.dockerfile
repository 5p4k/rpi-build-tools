ARG BASE_BUILDER_IMAGE=git-registry.mittelab.org/5p4k/rpi-build-tools/llvm7-arm

FROM debian:stretch-backports AS builder-sysroot
COPY cross-armv6-sources.list /root
WORKDIR /root
RUN apt-get -qq update \
    && apt-get install -yy --no-install-recommends \
        gnupg2 \
        dirmngr \
    && apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E \
    && mv /root/cross-armv6-sources.list /etc/apt/sources.list \
    && dpkg --add-architecture armhf \
    && apt-get update \
    && mkdir packages \
    && mkdir sysroot \
    && cd packages \
    && apt-get download \
        gcc-4.7-base:armhf \
        libc-bin:armhf \
        libc-dev-bin:armhf \
        libc6-dev:armhf \
        libc6:armhf \
        libgcc1:armhf \
        linux-libc-dev:armhf \
    && for pkg in *.deb; do \
            dpkg-deb --extract "${pkg}" /root/sysroot; \
        done \
    && cd \
    && rm -rf packages


FROM $BASE_BUILDER_IMAGE
COPY --from=builder-sysroot /root/sysroot /root/sysroot
