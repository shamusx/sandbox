#!/bin/bash

# Set target registry
TARGET_REGISTRY="<target_registry>"
VERSION="v1.17.0-alpha.0-11-g0dcecf5d85e35e"

# List of images and architectures
IMAGES=(
  "cert-manager-startupapicheck"
  "cert-manager-cainjector"
  "cert-manager-acmesolver"
  "cert-manager-webhook"
  "cert-manager-controller"
)

ARCHS=("amd64" "arm64" "arm" "ppc64le" "s390x")

# Push images
for image in "${IMAGES[@]}"; do
  for arch in "${ARCHS[@]}"; do
    LOCAL_IMAGE="${image}-${arch}:${VERSION}"
    REMOTE_IMAGE="${TARGET_REGISTRY}/${image}:${VERSION}-${arch}"

    echo "Tagging ${LOCAL_IMAGE} as ${REMOTE_IMAGE}..."
    docker tag "${LOCAL_IMAGE}" "${REMOTE_IMAGE}"

    echo "Pushing ${REMOTE_IMAGE}..."
    docker push "${REMOTE_IMAGE}"
  done
done

echo "All images pushed successfully!"
