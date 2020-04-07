ARG RASPBIAN_VERSION=buster

FROM debian:buster-slim
ARG RASPBIAN_VERSION
COPY "scripts/rpi-sysroot.sh" "/root"
COPY "_${RASPBIAN_VERSION}/packages.list" "/root/packages.list"
RUN apt-get -qq update \
    && apt-get install -yy --no-install-recommends file \
    && bash \
        /root/rpi-sysroot.sh \
            --version "${RASPBIAN_VERSION}" \
            --sysroot "/usr/share/rpi-sysroot" \
            --package-list "/root/packages.list" \
            --delete-unneeded
COPY "sysroot/*"  "/usr/share/rpi-sysroot/"
COPY "_${RASPBIAN_VERSION}/RPiStdLib.cmake" "/usr/share/rpi-sysroot/RPiStdLib.cmake"
RUN echo "RPi Sysoot size: $(du -sh /usr/share/rpi-sysroot)"
