#!/bin/bash

exec 2>&1
set -x

set +e && source "/etc/profile" &>/dev/null && set -e

BASE_IMAGE_EXISTS=$($WORKSTATION_SCRIPTS/image-updated.sh "$KIRA_DOCKER/base-image" "base-image" || echo "error")
if [ "$BASE_IMAGE_EXISTS" == "False" ]; then
    # todo: delete valdiator, sentry, kms, interx, frontend images
    $WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/frontend" "frontend"
    $WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/interx" "interx"
    $WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/kms" "kms"
    $WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/sentry" "sentry"
    $WORKSTATION_SCRIPTS/delete-image.sh "$KIRA_DOCKER/validator" "validator"

    echo "INFO: Updating base image..."
    $WORKSTATION_SCRIPTS/update-image.sh "$KIRA_DOCKER/base-image" "base-image" "latest" 
elif [ "$BASE_IMAGE_EXISTS" == "True" ]; then
    echo "INFO: base-image is up to date"
else
    echo "ERROR: Failed to test if base image exists"
    exit 1
fi
