ARG LLVM_VERSION=70
ARG LLVM_TARGETS=ARM
ARG LLVM_PROJECTS=""
ARG LLVM_TOOLS="clang lld"


FROM alpine AS builder-sources
ARG LLVM_VERSION
ARG LLVM_PROJECTS
ARG LLVM_TOOLS
WORKDIR /root
COPY fetch-llvm-src.sh ./
RUN apk add --no-cache --update \
        curl \
        file \
        unzip
RUN ash fetch-llvm-src.sh --projects "${LLVM_PROJECTS}" --tools "${LLVM_TOOLS}" --version "${LLVM_VERSION}"


FROM debian:stretch-backports AS builder-compiled
ARG LLVM_TARGETS
RUN apt-get -qq update \
    && apt-get -t stretch-backports -qq install -yy --no-install-recommends \
        cmake \
        python \
        libc++-dev \
        libc++abi-dev \
        libclang-common-6.0-dev \
        libc6-dev \
        llvm-6.0 \
        clang-6.0 \
        lld-6.0 \
        make
COPY --from=builder-sources /root/llvm /root/llvm
WORKDIR /root/build
RUN mkdir /root/prefix \
    && LLVM_TOOLCHAIN_LIB_DIR=$(llvm-config-6.0 --libdir) \
    && LD_FLAGS="" \
    && LD_FLAGS="${LD_FLAGS} -Wl,-L ${LLVM_TOOLCHAIN_LIB_DIR}" \
    && LD_FLAGS="${LD_FLAGS} -Wl,-rpath-link ${LLVM_TOOLCHAIN_LIB_DIR}" \
    && LD_FLAGS="${LD_FLAGS} -lc++ -lc++abi" \
    && CXX_FLAGS="-Wno-unused-command-line-argument" \
    && CXX_FLAGS="${CXX_FLAGS} -stdlib=libc++" \
    && cmake \
        -DCMAKE_C_COMPILER=clang-6.0 \
        -DCMAKE_CXX_COMPILER=clang++-6.0 \
        -DCMAKE_ASM_COMPILER=clang-6.0 \
        -DLLVM_ENABLE_PIC=NO \
        -DLLVM_TARGETS_TO_BUILD="${LLVM_TARGETS}" \
        -DCMAKE_CXX_FLAGS="${CXX_FLAGS}" \
        -DCMAKE_SHARED_LINKER_FLAGS="${LD_FLAGS}" \
        -DCMAKE_MODULE_LINKER_FLAGS="${LD_FLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LD_FLAGS}" \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_INSTALL_PREFIX=/root/prefix \
        -DLLVM_OPTIMIZED_TABLEGEN=YES \
        -DLLVM_INCLUDE_TESTS=NO \
        -DLIBCXX_USE_COMPILER_RT=YES \
        -DLIBCXXABI_USE_COMPILER_RT=YES \
        -DLLVM_ENABLE_LLD=YES \
        -DLIBCXX_CXX_ABI=libcxxabi \
        -DLIBCXX_CXX_ABI_INCLUDE_PATHS=/usr/include/libcxxabi \
        -DLIBCXXABI_USE_LLVM_UNWINDER=YES \
        /root/llvm \
    && echo "Total size of Makefiles:" \
    && du -sh .
RUN echo "Compiling LLVM using $(nproc) parallel jobs." \
    && make -j$(nproc) \
    && make -j$(nproc) install \
    && chown -R root:staff /root/prefix \
    && echo "Total size of the toolchain:" \
    && du -sh /root/prefix \
    && echo "Total size of Makefiles and build files together:" \
    && du -sh .


FROM debian:stretch-backports
COPY --from=builder-compiled /root/prefix /usr/local
RUN apt-get -qq update \
    && apt-get -t stretch-backports -qq install -yy --no-install-recommends \
        python \
        libc++1 \
        libc++abi1
RUN update-alternatives --install /usr/bin/cc cc /usr/local/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/local/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/cpp cpp /usr/local/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/ld ld /usr/local/bin/lld 100
