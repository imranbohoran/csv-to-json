#!/usr/bin/env bash

JOB_URL=$1
echo "Job url is ${JOB_URL}"
JOB_STATUS_URL=${JOB_URL}/lastBuild/api/json
echo "Job status url is ${JOB_STATUS_URL}"

DATE=$(date +%Y-%m-%d:%H:%M:%S)

curl --silent ${JOB_STATUS_URL} | grep result\":null > /dev/null
BUILD_STATUS_CODE=$?

echo "The build status is ${BUILD_STATUS_CODE}"
if [[ ${BUILD_STATUS_CODE} -eq 0 ]];
then
    BUILD_STATUS=success
else
    BUILD_STATUS=failed
fi

LATEST_RELEASE_NUMBER=$(git describe --abbrev=0 --match "release-*" | cut -d "-" -f 2)
let NEW_RELEASE_NUMBER=${LATEST_RELEASE_NUMBER}+1

TAG_NAME=release-${NEW_RELEASE_NUMBER}
echo "TAG to be created ${TAG_NAME}"

WORKING_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "The current working branch ${WORKING_BRANCH}"

git tag -a ${TAG_NAME} ${LATEST_COMMIT} -m "Release candidate tag created on ${DATE}"
git push --follow-tags

echo "Adding notes"
git notes add -f -m "release.tag=${TAG_NAME}"
git notes append -m "release.${TAG_NAME}.date=${DATE}"

git push origin "refs/notes/*"
