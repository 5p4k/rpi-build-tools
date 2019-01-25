#!/bin/bash

SOURCES_LIST="/etc/apt/sources.list"
RASPBIAN_ARCH="armhf"
DOWNLOAD_FOLDER="$(mktemp -d)"


RASPBIAN_SOURCES="deb http://archive.raspbian.org/raspbian stretch main contrib non-free rpi firmware"
RASPBIAN_KEY="9165938D90FDDD2E"
KEYSERVER="keyserver.ubuntu.com"
PACKAGE_LIST=()
DEFAULT_PACKAGE_LIST=(
    "gcc-4.7-base"
    "libc-bin"
    "libc-dev-bin"
    "libc6-dev"
    "libc6"
    "libgcc-4.7-dev"
    "libgcc1"
    "libgomp1"
    "libstdc++6-4.7-dev"
    "libstdc++6"
    "linux-libc-dev"
)
SYSROOT="/root/sysroot"
APPEND_DEFAULT_PACKAGES=1


function echo-run() {
    echo "$@"
    "$@"
}


function usage() {
    echo "$0 [-s|--sysroot <sysroot_folder>] [-n|--no-default-packages] [<packages> ...]"
    echo "$0 -h|--help"
    echo ""
    echo "Default sysroot: ${SYSROOT}"
    echo "Default pacakge list: ${DEFAULT_PACKAGE_LIST}"
}


while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--sysroot)
            shift
            SYSROOT="$1"
            ;;
        -n|--no-default-packages)
            APPEND_DEFAULT_PACKAGES=0
            ;;
        -h|--help)
            usage
            exit
            ;;
        *)
            PACKAGE_LIST+=("$1")
            ;;
    esac
    shift
done

if [[ ${APPEND_DEFAULT_PACKAGES} -ne 0 ]]; then
    PACKAGE_LIST+=("${DEFAULT_PACKAGE_LIST[@]}")
fi

# Make unique
PACKAGE_LIST=($(tr ' ' '\n' <<< "${PACKAGE_LIST[@]}" | sort -u | tr '\n' ' '))

echo ">> The script will prepare a sysroot in ${SYSROOT} with the following packages:"
I=0
for PACKAGE in "${PACKAGE_LIST[@]}"; do
    I=$(( I + 1 ))
    echo ">>  $(printf '%2d' "$I"). ${PACKAGE}"
done

echo ">> Updating apt..."

echo-run apt-get -qq update

echo ">> Installing gnupg2 and dirmngr..."

# You need gnupg2 and dirmngr to import a key with apt-key
echo-run apt-get install -qq -yy --no-install-recommends gnupg2 dirmngr

echo ">> Importing Raspbian key..."

# Import Raspberry Pi key
echo-run apt-key adv --no-tty --keyserver "${KEYSERVER}" --recv-keys "${RASPBIAN_KEY}"

echo ">> Updating apt for Raspbian packages..."

# Patch the sources.list
mv "${SOURCES_LIST}" "${SOURCES_LIST}.old"
echo "${RASPBIAN_SOURCES}" > "${SOURCES_LIST}"
echo-run dpkg --add-architecture "${RASPBIAN_ARCH}"

# Update, now only Raspbian packages are known to APT
echo-run apt-get -qq update

echo ">> Downloading all packages. Ignore errors about owner of the folder..."

# Build the command line
CMD=("apt-get" "download" "-qq")
for PACKAGE in "${PACKAGE_LIST[@]}"; do
    # Make sure there is only one :armhf at the end
    if [[ "${PACKAGE}" == *:"${RASPBIAN_ARCH}" ]]; then
        CMD+=("${PACKAGE}")
    else
        CMD+=("${PACKAGE}:${RASPBIAN_ARCH}")
    fi
done

pushd "${DOWNLOAD_FOLDER}"
echo-run "${CMD[@]}"
popd

echo ">> Restoring previous apt cache."

# Restore the sources list
mv "${SOURCES_LIST}.old" "${SOURCES_LIST}"
echo-run dpkg --remove-architecture "${RASPBIAN_ARCH}"
echo-run apt-get -qq update

echo ">> Listing all downloaded packages:"

find "${DOWNLOAD_FOLDER}" -type f -name \*.deb

echo ">> Extracting all packages to ${SYSROOT}..."

[[ -d "${SYSROOT}" ]] || mkdir -p "${SYSROOT}"

find "${DOWNLOAD_FOLDER}" -type f -name \*.deb | while read DEB; do
    echo-run dpkg-deb --extract "${DEB}" "${SYSROOT}"
done

echo ">> Completed, removing package files."

rm -rf "${DOWNLOAD_FOLDER}"
