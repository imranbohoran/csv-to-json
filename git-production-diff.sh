#!/bin/bash

PRODUCTION_TAG=$(git describe --abbrev=0 --match "production-*")
echo "Current production tag is ${PRODUCTION_TAG}"

CURRENT_PROD_COMMIT=$(git rev-list -n 1 ${PRODUCTION_TAG})
echo "Current production commit is ${CURRENT_PROD_COMMIT}"

CURRENT_PROD_RC_TAG=$(git notes show ${CURRENT_PROD_COMMIT} | grep rc.tag | cut -d " " -f 1 | cut -d"=" -f 2)
echo "Current production release tag ${CURRENT_PROD_RC_TAG}"

LATEST_STAGE_RELEASE_TAG=$(git describe --abbrev=0 --match "staging-*")
echo "Latest release tag ${LATEST_STAGE_RELEASE_TAG}"

COMMITS_SINCE_LAST_PROD=$(git rev-list --merges --tags=staging ${CURRENT_PROD_RC_TAG}..${LATEST_STAGE_RELEASE_TAG})
echo "Commits since last production ${COMMITS_SINCE_LAST_PROD}"

FILTER_SUCCESS_STAGE=$(echo "staging."${LATEST_STAGE_RELEASE_TAG}".status=success")
echo "Staging tag to look for ${FILTER_SUCCESS_STAGE}"

echo ""
echo ""
echo ""

echo ">>>>>> Available release candidates  <<<<<<<"
echo ""

for commit in ${COMMITS_SINCE_LAST_PROD};
do
  IS_SUCCESS=$(git notes show ${commit} | grep ${FILTER_SUCCESS_STAGE})
  if [ ${IS_SUCCESS} ]; then
    echo "Commit - $commit"
    TAG=$(git tag -l staging* --points-at ${commit})
    echo "Tag - $TAG"
    git log --graph --oneline ${CURRENT_PROD_RC_TAG}..${TAG}
    echo "                                               "
    echo " ********************************************  "
    echo "                                               "
  fi
done


