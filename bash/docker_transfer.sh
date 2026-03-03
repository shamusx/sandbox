#!/bin/bash

# Ensure the script exits if any command fails
set -e
gcloud auth configure-docker \
    us-east1-docker.pkg.dev
# Variables - Customize these with your specific details
IMAGE_NAME="spm-user"
IMAGE_VERSION="5577836331a3fa9841e81ebbad0e9b17b54142d3"  # or use something like "v1.0.0"
SOURCE_REGISTRY="<source_registry>"
TARGET_REGISTRY="<target_registry>"
TARGET_REPOSITORY="registryrepository"

# Full image paths
SOURCE_IMAGE="${SOURCE_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}"
TARGET_IMAGE="${TARGET_REGISTRY}/${TARGET_REPOSITORY}/${IMAGE_NAME}:${IMAGE_VERSION}"

# Step 1: Pull the x86 (amd64) image from the source registry
echo "Pulling x86 (amd64) image from source registry: ${SOURCE_IMAGE}"
docker pull --platform linux/amd64 "${SOURCE_IMAGE}"

# Step 2: Tag the image with the target registry name
echo "Tagging image with new registry: ${TARGET_IMAGE}"
docker tag "${SOURCE_IMAGE}" "${TARGET_IMAGE}"

# Step 3: Push the image to the target registry
echo "Pushing image to target registry: ${TARGET_IMAGE}"
docker push "${TARGET_IMAGE}"

# Success message
echo "Image pushed successfully to ${TARGET_IMAGE}"