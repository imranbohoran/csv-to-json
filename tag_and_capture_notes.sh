#!/usr/bin/env bash

source ./config.sh

JOB_URL=$1
ENVIRONMENT=$2
COMMIT_HASH=$3

if [[ ${ENVIRONMENT} == test* ]]
then
    echo "Tagging Test environment"
    ./release_tag_and_capture_notes.sh
fi

if [[ ${ENVIRONMENT} == integration* ]]
then
    echo "Tagging Staging environment"
    if [[ ${COMMIT_HASH} == "latest-master" ]]
    then
        echo "Getting commit for latest-master"
        COMMIT_TO_LOOKUP_TAG=$(git rev-parse HEAD)

    else
        echo "Using commit ${COMMIT_HASH}"
        COMMIT_TO_LOOKUP_TAG=${COMMIT_HASH}
    fi

    RELEASE_CANDIDATE_TAG=$(git tag -l ${RELEASE_CANDIDATE_TAG_PREFIX}-* --points-at ${COMMIT_TO_LOOKUP_TAG})
    ./staging_tag_and_capture_notes.sh ${JOB_URL} ${RELEASE_CANDIDATE_TAG}
fi

if [[ ${ENVIRONMENT} == production* ]]
then
    echo "Tagging Production environment"
    if [[ ${COMMIT_HASH} == "latest-master" ]]
    then
        echo "Getting commit for latest-master"
        COMMIT_TO_LOOKUP_TAG=$(git rev-parse HEAD)

    else
        echo "Using commit ${COMMIT_HASH}"
        COMMIT_TO_LOOKUP_TAG=${COMMIT_HASH}
    fi

    STAGING_TAG=$(git tag -l ${STAGING_TAG_PREFIX}-* --points-at ${COMMIT_TO_LOOKUP_TAG})
    ./production_tag_and_capture_notes.sh ${JOB_URL} ${STAGING_TAG}
fi
