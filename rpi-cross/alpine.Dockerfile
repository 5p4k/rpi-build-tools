ARG HOST_IMAGE=alpine:3.11.5
ARG SYSROOT_IMAGE

FROM $HOST_IMAGE
RUN apk add --no-cache --update \
        file \
        clang \
        lld \
        make \
        llvm-dev \
        cmake \
        bash \
        dpkg
COPY --from=$SYSROOT_IMAGE "/usr/share/rpi-sysroot" "/usr/share/rpi-sysroot"
COPY "bin/*" "/usr/bin/"
RUN ln -s "/usr/share/rpi-sysroot/RPi.cmake" "/usr/share/RPi.cmake" \
    && /usr/share/rpi-sysroot/check-armv6
