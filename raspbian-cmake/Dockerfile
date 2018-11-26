ARG CMAKE_VERSION=3.12.4


FROM resin/rpi-raspbian AS raspbian-build-essential
RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        build-essential \
        file


FROM raspbian-build-essential AS raspbian-cmake-bootstrapped
ARG CMAKE_VERSION
ENV CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz"
WORKDIR /root
RUN echo "Fetching CMake ${CMAKE_VERSION} from ${CMAKE_URL}" \
    && curl -L -o cmake.tar.gz "${CMAKE_URL}" \
    && file cmake.tar.gz \
    && mkdir cmake \
    && tar -C cmake --strip-components=1 -xvf cmake.tar.gz cmake-${CMAKE_VERSION}/ \
    && rm cmake.tar.gz
WORKDIR /root/cmake
RUN echo "Bootstrapping CMake using $(nproc) parallel nodes." \
    && mkdir sysroot \
    && ./bootstrap --parallel=$(nproc) --prefix=$(pwd)/sysroot -- -DCMAKE_BUILD_TYPE:STRING=Release


FROM raspbian-build-essential AS raspbian-cmake-compiled
WORKDIR /root/cmake
COPY --from=raspbian-cmake-bootstrapped /root/cmake .
RUN echo "Compiling CMake using $(nproc) parallel jobs." \
    && make -j $(nproc) \
    && make install


FROM raspbian-build-essential
LABEL maintainer="Pietro Saccardi <lizardm4@gmail.com>"
COPY --from=raspbian-cmake-compiled /root/cmake/sysroot /usr/local
