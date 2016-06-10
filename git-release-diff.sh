#!/bin/bash

PRODUCTION_TAG=`git describe --abbrev=0 --match "production-*"`
echo "Production tag is ${PRODUCTION_TAG}"

CURRENT_PROD_COMMIT=`git rev-list -n 1 ${PRODUCTION_TAG}`
echo "Current production commit is ${CURRENT_PROD_COMMIT}"

CURRENT_PROD_RC_TAG=$(git notes show ${CURRENT_PROD_COMMIT} | grep rc.tag | cut -d " " -f 1 | cut -d"=" -f 2)
echo "Current production release tag ${CURRENT_PROD_RC_TAG}"

LATEST_RELEASE_TAG=`git describe --abbrev=0 --match "release-*"`
echo "Latest release tag ${LATEST_RELEASE_TAG}"

COMMITS_SINCE_LAST_PROD=`git rev-list --merges --tags=release ${CURRENT_PROD_RC_TAG}..${LATEST_RELEASE_TAG}`
echo "Commits since last production ${COMMITS_SINCE_LAST_PROD}"

echo "Available release candidates"

for commit in ${COMMITS_SINCE_LAST_PROD};
do
  echo "Coomit - $commit"
  release_candidate_tag=`git tag -l release* --points-at $commit`
  echo "Tag - $release_candidate_tag"
  git log $CURRENT_PROD_RC_TAG..$release_candidate_tag
  echo "                                               "
  echo " ********************************************  "
  echo "                                               "
done


