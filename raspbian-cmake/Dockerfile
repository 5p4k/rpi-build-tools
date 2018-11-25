FROM resin/rpi-raspbian
LABEL maintainer="Pietro Saccardi <lizardm4@gmail.com>"
RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends build-essential \
    && cd \
    && curl -L https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4.tar.gz | tar xzv \
    && cd cmake-3.12.4 \
    && ./bootstrap
