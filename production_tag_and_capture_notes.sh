#!/usr/bin/env bash

source ./config.sh

JOB_URL=$1
echo "Job url is ${JOB_URL}"
JOB_STATUS_URL=${JOB_URL}/lastBuild/api/json

echo "Job status url is ${JOB_STATUS_URL}"

STAGING_TAG=$2
echo "The release staging tag ${STAGING_TAG}"

if [[ ${STAGING_TAG} != ${STAGING_TAG_PREFIX}-* ]]
then
    echo "${STAGING_TAG} is not a valid staging tag"
    exit 1
fi

curl --silent ${JOB_STATUS_URL} | grep '"result":"SUCCESS"' > /dev/null
BUILD_STATUS_CODE=$?

echo "The build status is ${BUILD_STATUS_CODE}"
if [[ ${BUILD_STATUS_CODE} -eq 0 ]];
then
    BUILD_STATUS=success
else
    BUILD_STATUS=failed
fi

COMMIT_FOR_RELEASE=$(git rev-list -n 1 ${STAGING_TAG})
echo "Commit for release ${COMMIT_FOR_RELEASE}"

NEW_RELEASE_NUMBER=$(echo ${STAGING_TAG} | cut -d "-" -f 2)

TAG_NAME=${PRODUCTION_TAG_PREFIX}-${NEW_RELEASE_NUMBER}
echo "TAG to be created ${TAG_NAME}"

DATE=$(date +%Y-%m-%d:%H:%M:%S)

git tag -a ${TAG_NAME} ${COMMIT_FOR_RELEASE} -m "Production tag created on ${DATE}"
git push origin ${TAG_NAME}

DATE=$(date +%Y-%m-%d:%H:%M:%S)

echo "Adding notes pre production build"
git checkout master
git pull --rebase
git fetch origin refs/notes/*:refs/notes/*

git notes append -m "production.tag=${TAG_NAME}" ${COMMIT_FOR_RELEASE}
git notes append -m "production.${TAG_NAME}.date=${DATE}" ${COMMIT_FOR_RELEASE}
git notes append -m "production.${TAG_NAME}.status=${BUILD_STATUS}" ${COMMIT_FOR_RELEASE}

git push origin refs/notes/commits
git push origin "refs/notes/*"
