#!/bin/bash

STAGING_TAG=$(git describe --abbrev=0 --match "staging-*")
echo "Current staging tag is ${STAGING_TAG}"

CURRENT_STAG_COMMIT=$(git rev-list -n 1 ${STAGING_TAG})
echo "Current staging commit is ${CURRENT_STAG_COMMIT}"

CURRENT_STAG_RC_TAG=$(git notes show ${CURRENT_STAG_COMMIT} | grep rc.tag | cut -d " " -f 1 | cut -d"=" -f 2)
echo "Current staging release tag ${CURRENT_STAG_RC_TAG}"

LATEST_RELEASE_TAG=$(git describe --abbrev=0 --match "release-*")
echo "Latest release tag ${LATEST_RELEASE_TAG}"

COMMITS_SINCE_LAST_STAG=$(git rev-list --merges --tags=release ${CURRENT_STAG_RC_TAG}..${LATEST_RELEASE_TAG})
echo "Commits since last staging ${COMMITS_SINCE_LAST_STAG}"

echo "Available release candidates"

for commit in ${COMMITS_SINCE_LAST_STAG};
do
  echo "Commit - $commit"
  RELEASE_CANDIDATE_TAG=$(git tag -l release* --points-at ${commit})
  echo "Tag - ${RELEASE_CANDIDATE_TAG}"
  git log --graph --oneline ${CURRENT_STAG_RC_TAG}..${RELEASE_CANDIDATE_TAG}
  echo "                                               "
  echo " ********************************************  "
  echo "                                               "
done


