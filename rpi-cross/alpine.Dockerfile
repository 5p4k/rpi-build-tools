ARG HOST_IMAGE=alpine:3.11.5
ARG RASPBIAN_VERSION=buster

FROM debian:buster-slim AS builder-sysroot
ARG RASPBIAN_VERSION
COPY "shared/scripts/rpi-sysroot.sh" "/root"
COPY "_${RASPBIAN_VERSION}/packages.list" "/root/packages.list"
RUN apt-get -qq update \
    && apt-get install -yy --no-install-recommends file \
    && bash \
        /root/rpi-sysroot.sh \
            --version "${RASPBIAN_VERSION}" \
            --sysroot "/usr/share/rpi-sysroot" \
            --package-list "/root/packages.list" \
            --delete-unneeded \
    && echo "RPi Sysoot size: $(du -sh /usr/share/rpi-sysroot)"

FROM $HOST_IMAGE
ARG RASPBIAN_VERSION
RUN apk add --no-cache --update \
        file \
        clang \
        lld \
        make \
        llvm-dev \
        cmake \
        bash \
        dpkg
COPY --from=builder-sysroot "/usr/share/rpi-sysroot" "/usr/share/rpi-sysroot"
COPY "shared/bin/*"                   "/usr/bin/"
COPY "shared/sysroot/*"               "/usr/share/rpi-sysroot/"
COPY "_${RASPBIAN_VERSION}/sysroot/*" "/usr/share/rpi-sysroot/"
RUN find /usr/share/rpi-sysroot -maxdepth 1 -name \*.cmake -exec ln -s {} /usr/share/ \; \
    && /usr/share/rpi-sysroot/check-armv6
