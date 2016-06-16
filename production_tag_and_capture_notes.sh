#!/usr/bin/env bash

JOB_URL=$1
echo "Job url is ${JOB_URL}"
# Hardcoded for now, it should be based off the ${JOB_URL}/lastBuild/api/json
JOB_STATUS_URL=http://localhost:8080/job/Deploy%20to%20Production/lastBuild/api/json

echo "Job status url is ${JOB_STATUS_URL}"

RELEASE_STAGING_TAG=$2
echo "The release staging tag ${RELEASE_STAGING_TAG}"

curl --silent ${JOB_STATUS_URL} | grep '"result":"SUCCESS"' > /dev/null
BUILD_STATUS_CODE=$?

echo "The build status is ${BUILD_STATUS_CODE}"
if [[ ${BUILD_STATUS_CODE} -eq 0 ]];
then
    BUILD_STATUS=success
else
    BUILD_STATUS=failed
fi

COMMIT_FOR_RELEASE=$(git rev-list -n 1 ${RELEASE_STAGING_TAG})
echo "Commit for release ${COMMIT_FOR_RELEASE}"

LATEST_RELEASE_NUMBER=$(git describe --abbrev=0 --match "production-*" | cut -d "-" -f 2)
number_regex='^[0-9]+$'
if ! [[ ${LATEST_RELEASE_NUMBER} =~ $number_regex ]]; then
   LATEST_RELEASE_NUMBER=0
fi

let NEW_RELEASE_NUMBER=${LATEST_RELEASE_NUMBER}+1

TAG_NAME=production-${NEW_RELEASE_NUMBER}
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
