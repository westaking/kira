#!/bin/bash

exec 2>&1
set -x

set +e && source "/etc/profile" &>/dev/null && set -e

SEKAI_HASH=$($KIRA_SCRIPTS/git-hash.sh $KIRA_SEKAI)
SEKAI_INTEGRITY="${SEKAI_BRANCH}_${SEKAI_HASH}"

SENTRY_IMAGE_EXISTS=$($KIRAMGR_SCRIPTS/image-updated.sh "$KIRA_DOCKER/sentry" "sentry" "latest" "$SEKAI_INTEGRITY" || echo "error")
if [ "$SENTRY_IMAGE_EXISTS" == "False" ]; then
    echo "All imags were updated, starting sentry image..."
    $KIRAMGR_SCRIPTS/update-image.sh "$KIRA_DOCKER/sentry" "sentry" "latest" "$SEKAI_INTEGRITY" "REPO=$SEKAI_REPO" "BRANCH=$SEKAI_BRANCH" #4
elif [ "$SENTRY_IMAGE_EXISTS" == "True" ]; then
    echo "INFO: sentry-image is up to date"
else
    echo "ERROR: Failed to test if sentry image exists"
    exit 1
fi
