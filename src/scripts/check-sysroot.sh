#!/bin/bash

SCRIPT_FOLDER="$(cd "$(dirname "$0")"; pwd -P)"
ARCH_CHECK="${SCRIPT_FOLDER}/arch-check.sh"
SYSROOT="${SCRIPT_FOLDER}"

if [[ $# -gt 0 ]]; then
    SYSROOT="$1"
fi

find "$SYSROOT" -type f -print0 | xargs -0 "$ARCH_CHECK" --ensure v6 --no-print-arch --no-print-matching
