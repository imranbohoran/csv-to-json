#!/usr/bin/env bash

RELEASE_CANDIDATE_TAG=$1
echo "The release candidate tag ${RELEASE_CANDIDATE_TAG}"

COMMIT_FOR_RELEASE_CANDIDATE=$(git rev-list -n 1 ${RELEASE_CANDIDATE_TAG})
echo "Commit for release candidate ${COMMIT_FOR_RELEASE_CANDIDATE}"


LATEST_RELEASE_NUMBER=$(echo ${RELEASE_CANDIDATE_TAG} | cut -d "-" -f 2)

let NEW_RELEASE_NUMBER=${LATEST_RELEASE_NUMBER}+1

TAG_NAME=staging-${NEW_RELEASE_NUMBER}
echo "TAG to be created ${TAG_NAME}"

git tag -a ${TAG_NAME} ${COMMIT_FOR_RELEASE_CANDIDATE} -m "Staging tag created on ${DATE}"
git push origin ${TAG_NAME}

DATE=$(date +%Y-%m-%d:%H:%M:%S)

echo "Adding notes pre staging build"
git checkout master
git pull --rebase
git fetch origin refs/notes/*:refs/notes/*

git notes append -m "stage.tag=${TAG_NAME}" ${COMMIT_FOR_RELEASE_CANDIDATE}
git notes append -m "stage.${TAG_NAME}.date=${DATE}" ${COMMIT_FOR_RELEASE_CANDIDATE}

git push origin refs/notes/commits
git push origin "refs/notes/*"
