#!/usr/bin/env bash

JOB_URL=$1
echo "Job url is ${JOB_URL}"
JOB_STATUS_URL=${JOB_URL}/lastBuild/api/json
echo "Job status url is ${JOB_STATUS_URL}"

DATE=$(date +%Y-%m-%d:%H:%M:%S)

LATEST_RELEASE_NUMBER=$(git describe --abbrev=0 --match "release-*" | cut -d "-" -f 2)
number_regex='^[0-9]+$'
if ! [[ ${LATEST_RELEASE_NUMBER} =~ $number_regex ]]; then
   LATEST_RELEASE_NUMBER=0
fi

let NEW_RELEASE_NUMBER=${LATEST_RELEASE_NUMBER}+1

LATEST_COMMIT=$(git rev-parse origin/master^{commit})

TAG_NAME=release-${NEW_RELEASE_NUMBER}
echo "TAG to be created ${TAG_NAME}"

git tag -a ${TAG_NAME} ${LATEST_COMMIT} -m "Release candidate tag created on ${DATE}"
git push origin ${TAG_NAME}

echo "Adding notes"
git checkout master
git pull --rebase
git fetch origin refs/notes/*:refs/notes/*

git notes add -f -m "release.tag=${TAG_NAME}" ${LATEST_COMMIT}
git notes append -m "release.${TAG_NAME}.date=${DATE}" ${LATEST_COMMIT}

git push origin refs/notes/commits
git push origin "refs/notes/*"
