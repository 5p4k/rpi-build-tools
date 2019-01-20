#!/bin/bash

if [[ -z "${CI_REGISTRY}" ]] \
    || [[ -z "${CI_PROJECT_PATH}" ]] \
    || [[ -z "${CI_COMMIT_SHA}" ]] \
    || [[ -z "${CI_JOB_TOKEN}" ]]; then

    echo "You are not running inside Gitlab CI."
    echo "This script requires the following variables to be set:"
    echo " - CI_REGISTRY"
    echo " - CI_PROJECT_PATH"
    echo " - CI_COMMIT_SHA"
    echo " - CI_JOB_TOKEN"
    exit 1
fi

function usage() {
    echo "$0 [--build-arg KEY=VAL [...]] --image-tag IMAGE_TAG DOCKERFILE"
}

IMAGE_TAG=""
BUILD_ARGS=()
DOCKERFILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--build-arg)
            shift
            BUILD_ARGS+=("$1")
            ;;
        -t|--image-tag)
            shift
            IMAGE_TAG="$1"
            ;;
        *)
            DOCKERFILE="$1"
            ;;
    esac
    shift
done

if [[ -z "${IMAGE_TAG}" ]] || [[ -z "${DOCKERFILE}" ]]; then
    usage
    exit 0
fi

if ! [[ -f "${DOCKERFILE}" ]]; then
    echo "File ${DOCKERFILE} does not exist."
    exit 1
fi

CONTAINER_IMAGE="${CI_REGISTRY}/${CI_PROJECT_PATH}/${IMAGE_TAG}"
BUILD_CMDLINE=("docker" "build")

echo "Container image: ${CONTAINER_IMAGE}"
echo "Tags to build: ${CI_COMMIT_SHA}, latest"
echo "Dockerfile: ${DOCKERFILE}"
echo "Build arguments:"

I=0
for ARG in "${BUILD_ARGS[@]}"; do
    BUILD_CMDLINE+=("--build-arg" "${ARG}")
    I=$(( I + 1 ))
    echo "  $I. ${ARG}"
done


BUILD_CMDLINE+=("--cache-from" "${CONTAINER_IMAGE}:latest")
BUILD_CMDLINE+=("--file" "${DOCKERFILE}")
BUILD_CMDLINE+=("--tag" "${CONTAINER_IMAGE}:${CI_COMMIT_SHA}")
BUILD_CMDLINE+=("--tag" "${CONTAINER_IMAGE}:latest")
BUILD_CMDLINE+=("$(dirname "${DOCKERFILE}")")

echo "Build command: ${BUILD_CMDLINE[*]}"

echo "Logging in..."

docker login -u gitlab-ci-token -p "${CI_JOB_TOKEN}" "${CI_REGISTRY}"

echo "Building..."
"${BUILD_CMDLINE[@]}"

RES=$?

if [[ ${RES} -ne 0 ]]; then
    exit ${RES}
fi

echo "Pushing..."

docker push "${CONTAINER_IMAGE}:${CI_COMMIT_SHA}"
docker push "${CONTAINER_IMAGE}:latest"
