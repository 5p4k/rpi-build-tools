#!/bin/bash

SOURCES_LIST="/etc/apt/sources.list"
RASPBIAN_ARCH="armhf"
DOWNLOAD_FOLDER="$(mktemp -d)"
RASPBIAN_VERSION="buster"


RASPBIAN_KEY="9165938D90FDDD2E"
KEYSERVER="keyserver.ubuntu.com"
EXTRA_PACKAGES=()
SYSROOT="/usr/share/rpi-sysroot"
PACKAGE_LIST_FILE=""


function echo_run() {
    echo "$@"
    "$@"
}


function usage() {
    echo "$0 [-s|--sysroot <sysroot_folder>] [-v|--version <raspbian_version>] \\"
    echo "   [-p|--package-list <pkg_list_file>] [<other_packages> ...]"
    echo ""
    echo "$0 -h|--help"
    echo ""
    echo "Default sysroot: ${SYSROOT}"
    echo "Default Raspbian version: ${RASPBIAN_VERSION}"
    echo ""
    echo "Downloads and unpacks the specified packages from the Raspbian armhf repository."
    echo "This is used to create a basic sysroot to cross-compile for the Raspberry Pi,"
    echo "starting directly from up-to-date packages."
}


while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--sysroot)
            shift
            SYSROOT="$1"
            ;;
        -v|--version)
            shift
            RASPBIAN_VERSION="$1"
            ;;
        -p|--package-list)
            shift
            PACKAGE_LIST_FILE="$1"
            ;;
        -h|--help)
            usage
            exit
            ;;
        *)
            EXTRA_PACKAGES+=("$1")
            ;;
    esac
    shift
done

# Assemble a list of packages
TEMP_PACKAGES_LIST_FILE="$(mktemp)"
if [ -n "$PACKAGE_LIST_FILE" ]; then
    if ! [ -f "$PACKAGE_LIST_FILE" ]; then
        echo "Cannot find ${PACKAGE_LIST_FILE} at $(realpath "${PACKAGE_LIST_FILE}")."
        exit 1
    else
        cat "$PACKAGE_LIST_FILE" >> "$TEMP_PACKAGES_LIST_FILE"
    fi
fi
for PACKAGE in "${EXTRA_PACKAGES[@]}"; do
    echo "$PACKAGE" >> "$TEMP_PACKAGES_LIST_FILE"
done
UNIQUE_PACKAGES_LIST_FILE="$(mktemp)"
# Remove spaces, blank lines and sort unique
tr -d '[:blank:]' < "$TEMP_PACKAGES_LIST_FILE" \
    | sort --ignore-case --unique \
    | sed -e '/^$/d' > "$UNIQUE_PACKAGES_LIST_FILE"
rm "$TEMP_PACKAGES_LIST_FILE"

# Print the list of packages, convert that to a bash array
echo ">> The script will prepare a sysroot in ${SYSROOT} with the following packages:"

I=0
UNIQUE_PACKAGES_LIST=()
while read -r PACKAGE; do
    I=$(( I + 1 ))
    echo ">>  $(printf '%2d' "$I"). ${PACKAGE}"
    # Make sure there is only one :armhf at the end
    if [[ "${PACKAGE}" == *:"${RASPBIAN_ARCH}" ]]; then
        UNIQUE_PACKAGES_LIST+=("${PACKAGE}")
    else
        UNIQUE_PACKAGES_LIST+=("${PACKAGE}:${RASPBIAN_ARCH}")
    fi
done < "$UNIQUE_PACKAGES_LIST_FILE"

rm "$UNIQUE_PACKAGES_LIST_FILE"

# Actually prepare the new sources list

RASPBIAN_SOURCES="deb http://archive.raspbian.org/raspbian ${RASPBIAN_VERSION} main contrib non-free rpi firmware"

echo ">> Updating apt..."

echo_run apt-get -qq update

echo ">> Installing gnupg2 and dirmngr..."

# You need gnupg2 and dirmngr to import a key with apt-key
echo_run apt-get install -qq -yy --no-install-recommends gnupg2 dirmngr

echo ">> Importing Raspbian key..."

# Import Raspberry Pi key
echo_run apt-key adv --no-tty --keyserver "${KEYSERVER}" --recv-keys "${RASPBIAN_KEY}"

echo ">> Updating apt for Raspbian packages..."

# Patch the sources.list
mv "${SOURCES_LIST}" "${SOURCES_LIST}.old"
echo "${RASPBIAN_SOURCES}" > "${SOURCES_LIST}"
echo_run dpkg --add-architecture "${RASPBIAN_ARCH}"

# Update, now only Raspbian packages are known to APT
echo_run apt-get -qq update

echo ">> Downloading all packages. Ignore errors about owner of the folder..."

# Build the command line and download
CMD=("apt-get" "download" "-qq" "${UNIQUE_PACKAGES_LIST[@]}")

pushd "${DOWNLOAD_FOLDER}" || exit 2
echo_run "${CMD[@]}"
popd || exit 2

echo ">> Restoring previous apt cache."

# Restore the sources list
mv "${SOURCES_LIST}.old" "${SOURCES_LIST}"
echo_run dpkg --remove-architecture "${RASPBIAN_ARCH}"
echo_run apt-get -qq update

echo ">> Listing all downloaded packages:"

find "${DOWNLOAD_FOLDER}" -type f -name \*.deb

echo ">> Extracting all packages to ${SYSROOT}..."

[[ -d "${SYSROOT}" ]] || mkdir -p "${SYSROOT}"

find "${DOWNLOAD_FOLDER}" -type f -name \*.deb | while read -r DEB; do
    echo_run dpkg-deb --extract "${DEB}" "${SYSROOT}"
done

echo ">> Completed, removing package files."

rm -rf "${DOWNLOAD_FOLDER}"
