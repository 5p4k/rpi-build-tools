FROM resin/rpi-raspbian AS raspbian-build
RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        libc-dev-bin \
        libc6-dev \
        libstdc++-4.9-dev \
        linux-libc-dev

FROM git-registry.mittelab.org/5p4k/rpi-build-tools/debian-clang-target-arm
COPY --from=raspbian-build /lib /root/sysroot/lib
COPY --from=raspbian-build /usr/include /root/sysroot/usr/include
COPY --from=raspbian-build /usr/lib /root/sysroot/usr/lib
COPY --from=raspbian-build /usr/local/include /root/sysroot/usr/local/include
COPY --from=raspbian-build /usr/local/lib /root/sysroot/usr/local/lib
# Also relevant, but included in the previous copies
# COPY --from=raspbian-build /lib/arm-linux-gnueabihf /root/sysroot/lib/arm-linux-gnueabihf
# COPY --from=raspbian-build /usr/include/arm-linux-gnueabihf /root/sysroot/usr/include/arm-linux-gnueabihf
# COPY --from=raspbian-build /usr/lib/arm-linux-gnueabihf /root/sysroot/usr/lib/arm-linux-gnueabihf
# COPY --from=raspbian-build /usr/lib/gcc/arm-linux-gnueabihf/4.9/include /root/sysroot/usr/lib/gcc/arm-linux-gnueabihf/4.9/include
# COPY --from=raspbian-build /usr/lib/gcc/arm-linux-gnueabihf/4.9/include-fixed /root/sysroot/usr/lib/gcc/arm-linux-gnueabihf/4.9/include-fixed
COPY clang-arm-linux-gnueabihf clang++-arm-linux-gnueabihf /usr/local/bin/
