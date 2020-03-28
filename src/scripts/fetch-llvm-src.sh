#!/bin/bash
LLVM_VERSION=90
LLVM_PROJECTS="compiler-rt libcxx libcxxabi libunwind"
LLVM_TOOLS="clang lld"
LLVM=1
TARGET="$(pwd)"

function optional_run() {
    if which "$1" > /dev/null; then
        "$@"
    fi
}

function ensure_or_install() {
    PROG="$1"
    shift
    if ! which "${PROG}" > /dev/null; then
        if [[ "$(whoami)" == "root" ]] && [[ -f /.dockerenv ]]; then
            echo "You need to install ${PROG} for this to work. I will install it for you since you are root in docker."
            if ! apt-get install -yy --no-install-recommends "$@"; then
                exit 1
            fi
        else
            echo "You need ${PROG} for this to work. Please install $*."
            exit 1
        fi
    fi
}

function help() {
    echo "Usage: download and arrange LLVM sources."
    echo "       $0 [-v|--version <llvm_version>] [--projects|-p <llvm_projects>] [--tools|-t <llvm_tools>] [--no-llvm] [<target>]"
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
        --no-llvm)
            LLVM=0
            ;;
        *)
            TARGET="$1"
            ;;
    esac
    shift
done

LLVM_PROJECTS_TOOLS="${LLVM_PROJECTS} ${LLVM_TOOLS}"

ensure_or_install curl curl ca-certificates
ensure_or_install unzip unzip

mkdir -p "${TARGET}"
cd "${TARGET}"

if [[ ${LLVM} -ne 0 ]]; then
    LLVM_PROJECTS_TOOLS="${LLVM_PROJECTS_TOOLS} llvm"
else
    for FOLDER in llvm llvm/projects llvm/tools; do
        if ! [[ -d "${FOLDER}" ]]; then
            mkdir -p "${FOLDER}"
        fi
    done
fi

for PROJ_TOOL in ${LLVM_PROJECTS_TOOLS}; do
    export PROJ_TOOL_URL="https://github.com/llvm-mirror/${PROJ_TOOL}/archive/release_${LLVM_VERSION}.zip"
    echo "Pulling ${PROJ_TOOL} from ${PROJ_TOOL_URL}"
    curl -L -o "${PROJ_TOOL}.zip" "${PROJ_TOOL_URL}"
    optional_run file "${PROJ_TOOL}.zip"
done
for PROJ_TOOL in ${LLVM_PROJECTS_TOOLS}; do
        unzip -q "${PROJ_TOOL}.zip"
        rm "${PROJ_TOOL}.zip"
        mv "${PROJ_TOOL}-release_${LLVM_VERSION}" "${PROJ_TOOL}"
done
for PROJ in ${LLVM_PROJECTS}; do
        mv "${PROJ}" "llvm/projects/${PROJ}"
done
for TOOL in ${LLVM_TOOLS}; do
        mv "${TOOL}" "llvm/tools/${TOOL}"
done
