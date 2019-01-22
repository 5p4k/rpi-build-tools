#!/bin/bash

function usage() {
    echo "$0 [--ensure <ARCH> [--no-print-arch] [--no-print-matching]] [--] <FILES> ..."
}

FILES=()
ENSURE_ARCH=""
PRINT_ARCH=1
PRINT_MATCHING=1

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ensure|-e)
            shift
            ENSURE_ARCH="$1"
            ;;
        --no-print-arch|-na)
            PRINT_ARCH=0
            ;;
        --no-print-matching|-nm)
            PRINT_MATCHING=0
            ;;
        *)
            if [[ "$1" == "--" ]]; then
                shift
                break
            else
                FILES+=("$1")
            fi
            ;;
    esac
    shift
done

if [[ $# -gt 0 ]]; then
    FILES+=("$@")
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    usage
    exit
fi

ALL_ARCHS=$(file "${FILES[@]}" |
    grep '\(ELF\|ar archive\)' |
    cut -d: -f1 |
    while read FILE; do
        readelf -A "${FILE}" |
            fgrep 'Tag_CPU_arch:' |
            awk '{print $2}' |
            while read ARCH; do
                echo "${FILE}: ${ARCH}"
            done
    done)

if ! [[ -z "${ENSURE_ARCH}" ]]; then
    MATCHING_ARCHS=$(echo "${ALL_ARCHS}" | grep ": ${ENSURE_ARCH}\$")
    if [[ $PRINT_ARCH -ne 0 ]]; then
        echo "${ALL_ARCHS}" | sort -u
    elif [[ $PRINT_MATCHING -ne 0 ]]; then
        echo "${MATCHING_ARCHS}" | sort -u
    fi
    N_TOTAL=$(echo "$ALL_ARCHS" | cut -d: -f1 | sort -u | wc -l)
    N_MATCHING=$(echo "$MATCHING_ARCHS" | cut -d: -f1 | sort -u | wc -l)
    N_MISMATCHING=$(( N_TOTAL - N_MATCHING ))

    if [[ $N_MISMATCHING -eq 0 ]]; then
        echo "All the ${N_TOTAL} binaries analyzes match the architecture ${ENSURE_ARCH}."
        exit 0
    else
        echo "There are ${N_MISMATCHING} out of ${N_TOTAL} binaries whose architecture does not match ${ENSURE_ARCH}."
        exit 1
    fi
else
    echo "$ALL_ARCHS"
fi
