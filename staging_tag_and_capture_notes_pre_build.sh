#!/usr/bin/env bash

source ./config.sh

RELEASE_CANDIDATE_TAG=$1
echo "The release candidate tag ${RELEASE_CANDIDATE_TAG}"

if [[ ${RELEASE_CANDIDATE_TAG} != ${RELEASE_CANDIDATE_TAG_PREFIX}-* ]]
then
    echo "${RELEASE_CANDIDATE_TAG} is not a valid release candidate tag"
    exit 1
fi

COMMIT_FOR_RELEASE_CANDIDATE=$(git rev-list -n 1 ${RELEASE_CANDIDATE_TAG})
echo "Commit for release candidate ${COMMIT_FOR_RELEASE_CANDIDATE}"

NEW_RELEASE_NUMBER=$(echo ${RELEASE_CANDIDATE_TAG} | cut -d "-" -f 2)

TAG_NAME=${STAGING_TAG_PREFIX}-${NEW_RELEASE_NUMBER}
echo "TAG to be created ${TAG_NAME}"

DATE=$(date +%Y-%m-%d:%H:%M:%S)

git tag -a ${TAG_NAME} ${COMMIT_FOR_RELEASE_CANDIDATE} -m "Staging tag created on ${DATE}"
git push origin ${TAG_NAME}


echo "Adding notes pre staging build"
git checkout master
git pull --rebase
git fetch origin refs/notes/*:refs/notes/*

git notes append -m "stage.tag=${TAG_NAME}" ${COMMIT_FOR_RELEASE_CANDIDATE}
git notes append -m "stage.${TAG_NAME}.date=${DATE}" ${COMMIT_FOR_RELEASE_CANDIDATE}

git push origin refs/notes/commits
git push origin "refs/notes/*"
