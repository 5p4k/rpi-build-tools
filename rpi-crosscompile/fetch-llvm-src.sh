#!/bin/bash
LLVM_VERSION=70
LLVM_PROJECTS="compiler-rt libcxx libcxxabi libunwind"
LLVM_TOOLS="clang lld"
TARGET="$(pwd)"

function help() {
    echo "Usage: download and arrange LLVM sources."
    echo "       $0 [-v|--version <llvm_version>] [--projects|-p <llvm_projects>] [--tools|-t <llvm_tools>] [<target>]"
    echo ""
    echo "Usage: display this help."
    echo "       $0 -h|--help"
    echo ""
    echo "Defaults:"
    echo "    llvm_version     ${LLVM_VERSION}"
    echo "    llvm_projects    ${LLVM_PROJECTS}"
    echo "    llvm_tools       ${LLVM_TOOLS}"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            help
            exit
            ;;
        -v|--version)
            shift
            LLVM_VERSION="$1"
            ;;
        -t|--tools)
            shift
            LLVM_TOOLS="$1"
            ;;
        -p|--projects)
            shift
            LLVM_PROJECTS="$1"
            ;;
        *)
            TARGET="$1"
            ;;
    esac
    shift
done

LLVM_PROJECTS_TOOLS="llvm ${LLVM_PROJECTS} ${LLVM_TOOLS}"

cd "${TARGET}"
for PROJ_TOOL in ${LLVM_PROJECTS_TOOLS}; do
    export PROJ_TOOL_URL="https://github.com/llvm-mirror/${PROJ_TOOL}/archive/release_${LLVM_VERSION}.zip"
    echo "Pulling ${PROJ_TOOL} from ${PROJ_TOOL_URL}"
    curl -L -o "${PROJ_TOOL}.zip" "${PROJ_TOOL_URL}"
    file "${PROJ_TOOL}.zip"
done
for PROJ_TOOL in ${LLVM_PROJECTS_TOOLS}; do
        unzip -q "${PROJ_TOOL}.zip"
        rm "${PROJ_TOOL}.zip"
        mv "${PROJ_TOOL}-release_${LLVM_VERSION}" "${PROJ_TOOL}"
done
for PROJ in ${LLVM_PROJECTS}; do
        mv "${PROJ}" llvm/projects
done
for TOOL in ${LLVM_TOOLS}; do
        mv "${TOOL}" llvm/tools
done
