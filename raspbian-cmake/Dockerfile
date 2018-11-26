LABEL maintainer="Pietro Saccardi <lizardm4@gmail.com>"


ARG CMAKE_VERSION=3.12.4


FROM resin/rpi-raspbian AS raspbian-build-essential
RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        build-essential


FROM raspbian-build-essential AS raspbian-cmake-bootstrapped
WORKDIR /root
RUN curl -L -o cmake-${CMAKE_VERSION}.tar.gz https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz \
    && tar -xzvf cmake-${CMAKE_VERSION}.tar.gz \
    && rm cmake-${CMAKE_VERSION}.tar.gz \
    && mv cmake-${CMAKE_VERSION} cmake
WORKDIR /root/cmake
RUN mkdir sysroot \
    && ./bootstrap --parallel=$(nproc) --prefix=$(pwd)/sysroot -- -DCMAKE_BUILD_TYPE:STRING=Release


FROM raspbian-build-essential AS raspbian-cmake-compiled
WORKDIR /root/cmake
COPY --from=raspbian-cmake-bootstrapped /root/cmake .
RUN make -j $(nproc) \
    && make install


FROM raspbian-build-essential
COPY --from=raspbian-cmake-compiled /root/cmake/sysroot /usr/local
