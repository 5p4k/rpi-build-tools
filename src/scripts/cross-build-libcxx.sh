#!/bin/bash

DEFAULT_LLVM_VERSION="60"
DEFAULT_TOOLCHAIN_FILE="/usr/share/RPiToolchain.cmake"
DEFAULT_BUILD_TYPE="MinSizeRel"
DEFAULT_PREFIX="/usr/share/rpi-sysroot/usr"

LLVM_VERSION="${DEFAULT_LLVM_VERSION}"
TOOLCHAIN_FILE="${DEFAULT_TOOLCHAIN_FILE}"
BUILD_TYPE="${DEFAULT_BUILD_TYPE}"
PREFIX="${DEFAULT_PREFIX}"

function usage() {
    echo "$0 [-v|--llvm-version <LLVM version>] [-b|--build-type <Build Type>] [-p|--install-prefix <Prefix>]"
    echo "$0 -h|--help"
    echo ""
    echo "Default LLVM version:   ${DEFAULT_LLVM_VERSION}"
    echo "Default install prefix: ${DEFAULT_PREFIX}"
    echo "Default build type:     ${DEFAULT_BUILD_TYPE}"
    echo "Default toolchain file: ${DEFAULT_TOOLCHAIN_FILE}"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--version|--llvm-version)
            shift
            LLVM_VERSION="$1"
            ;;
        -t|--toolchain)
            shift
            TOOLCHAIN_FILE="$1"
            ;;
        -b|--build|--build-type)
            shift
            BUILD_TYPE="$1"
            ;;
        -p|--prefix|--install-prefix)
            shift
            PREFIX="$1"
            ;;
        -h|--help)
            usage
            exit
            ;;
    esac
    shift
done

function echo-run() {
    echo "$@"
    "$@"
}

# https://stackoverflow.com/a/4774063/1749822
SCRIPT_FOLDER="$(cd "$(dirname "$0")"; pwd -P)"
FETCH_LLVM_SH="${SCRIPT_FOLDER}/fetch-llvm-src.sh"

if ! [[ -x "${FETCH_LLVM_SH}" ]]; then
    echo "Could not find ${FETCH_LLVM_SH}. It should be located in ${SCRIPT_FOLDER}."
    exit 1
fi

echo ">> The script will download and crosscompile libc++ and libc++abi with the following settings:"
echo ">>   LLVM version:         ${LLVM_VERSION}"
echo ">>   Toolchain CMake file: ${TOOLCHAIN_FILE}"
echo ">>   Build type:           ${BUILD_TYPE}"
echo ">>   Install prefix:       ${PREFIX}"


SOURCE_FOLDER="$(mktemp -d)"
BUILD_FOLDER="$(mktemp -d)"

echo-run "${FETCH_LLVM_SH}" --no-llvm --projects "libcxx libcxxabi" --tools "" --version "${LLVM_VERSION}" "${SOURCE_FOLDER}"

pushd "${BUILD_FOLDER}"

# -Wno-dev suppresses weird warnings about the CMake files
echo-run cmake \
    -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DLIBCXXABI_LIBCXX_PATH="${SOURCE_FOLDER}/llvm/projects/libcxx" \
    -DLIBCXXABI_LIBCXX_INCLUDES="${SOURCE_FOLDER}/llvm/projects/libcxx/include" \
    -Wno-dev \
    "${SOURCE_FOLDER}/llvm/projects/libcxxabi"
echo-run make -j "$(nproc)"
echo-run make install
echo-run rm -rf ./*
echo-run cmake \
    -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DLIBCXX_CXX_ABI="libcxxabi" \
    -DLIBCXX_CXX_ABI_INCLUDE_PATHS="${SOURCE_FOLDER}/llvm/projects/libcxxabi/include" \
    -DLIBCXX_CXX_ABI_LIBRARY_PATH="${PREFIX}/lib" \
    -Wno-dev \
    "${SOURCE_FOLDER}/llvm/projects/libcxx"
echo-run make -j "$(nproc)"
echo-run make install
echo-run rm -rf ./*
popd

echo-run rm -rf "${BUILD_FOLDER}"
echo-run rm -rf "${SOURCE_FOLDER}"
