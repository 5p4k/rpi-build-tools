ARG LLVM_VERSION=70

FROM alpine AS builder-sources
ARG LLVM_VERSION
WORKDIR /root
RUN apk add --update \
        curl \
        file \
        unzip \
    && export LLVM_PROJECTS_TOOLS="llvm clang clang-tools-extra lld polly compiler-rt openmp libcxx libcxxabi" \
    && for PROJ_TOOL in ${LLVM_PROJECTS_TOOLS}; do \
        export PROJ_TOOL_URL="https://github.com/llvm-mirror/${PROJ_TOOL}/archive/release_${LLVM_VERSION}.zip"; \
        echo "Pulling ${PROJ_TOOL} from ${PROJ_TOOL_URL}"; \
        curl -L -o ${PROJ_TOOL}.zip "${PROJ_TOOL_URL}"; \
        file ${PROJ_TOOL}.zip; \
    done \
    && for PROJ_TOOL in ${LLVM_PROJECTS_TOOLS}; do \
        unzip -q ${PROJ_TOOL}.zip; \
        rm ${PROJ_TOOL}.zip; \
        mv ${PROJ_TOOL}-release_${LLVM_VERSION} ${PROJ_TOOL}; \
    done \
    && mv compiler-rt llvm/projects \
    && mv libcxx llvm/projects \
    && mv libcxxabi llvm/projects \
    && mv openmp llvm/projects \
    && mv clang llvm/tools \
    && mv lld llvm/tools \
    && mv polly llvm/tools \
    && mv clang-tools-extra llvm/tools/clang/tools \
    && rm -rf clang-tools-extra


FROM debian AS builder-compiled
COPY --from=builder-sources /root/llvm /root/llvm
WORKDIR /root/build
RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        build-essential \
        cmake \
        python \
        zip \
        unzip \
        zlib1g \
    && mkdir /root/prefix \
    && cmake -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_INSTALL_PREFIX=/root/prefix \
        -DLLVM_OPTIMIZED_TABLEGEN=ON \
        -DLLVM_TARGETS_TO_BUILD="ARM" \
        -DLLVM_INCLUDE_TESTS=OFF \
        /root/llvm \
    && echo "Compiling LLVM using $(nproc) parallel jobs." \
    && make -j$(nproc) \
    && make install \
    && chown -R root:staff /root/prefix \
    && echo "Total size of the toolchain:" \
    && du -sh /root/prefix


FROM debian
COPY --from=builder-compiled /root/prefix /usr/local
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/local/bin/clang++ 100 \
   && update-alternatives --install /usr/bin/clang clang   /usr/local/bin/clang   100 \
   && update-alternatives --install /usr/bin/cc cc         /usr/local/bin/clang   100 \
   && update-alternatives --install /usr/bin/c++ c++       /usr/local/bin/clang++ 100 \
   && update-alternatives --install /usr/bin/cpp cpp       /usr/local/bin/clang++ 100 \
   && update-alternatives --install /usr/bin/ld ld         /usr/local/bin/lld     100

