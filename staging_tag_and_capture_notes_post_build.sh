#!/usr/bin/env bash

JOB_URL=$1
echo "Job url is ${JOB_URL}"
JOB_STATUS_URL=${JOB_URL}/lastBuild/api/json
echo "Job status url is ${JOB_STATUS_URL}"

RELEASE_CANDIDATE_TAG=$2
echo "The release candidate tag ${RELEASE_CANDIDATE_TAG}"

curl --silent ${JOB_STATUS_URL} | grep '"result":"SUCCESS"' > /dev/null
BUILD_STATUS_CODE=$?

echo "The build status is ${BUILD_STATUS_CODE}"
if [[ ${BUILD_STATUS_CODE} -eq 0 ]];
then
    BUILD_STATUS=success
else
    BUILD_STATUS=failed
fi

CURRENT_STAGING_TAG=$(git describe --abbrev=0 --match "staging-*")

COMMIT_FOR_CURRENT_STAGING=$(git rev-list -n 1 ${CURRENT_STAGING_TAG})
echo "Commit for release candidate ${COMMIT_FOR_CURRENT_STAGING}"

echo "Appending notes"
git checkout master
git pull --rebase master
git fetch origin refs/notes/*:refs/notes/*

git notes append -m "stage.${CURRENT_STAGING_TAG}.date=${BUILD_STATUS}" ${COMMIT_FOR_CURRENT_STAGING}

git push origin refs/notes/commits
git push origin "refs/notes/*"
