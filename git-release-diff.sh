#!/bin/bash

PRODUCTION_TAG=`git describe --match "production-*"`
echo "Production tag is ${PRODUCTION_TAG}"

STAGING_TAG=`git describe --match "staging-*"`
echo "Staging tag is ${STAGING_TAG}"

INTEGRATION_TAG=`git describe --match "release-*"`
echo "Integration tag is ${INTEGRATION_TAG}"

echo "The following releases are available: "
LATEST_CHANGES=`git log  --decorate --simplify-by-decoration  --tags ${PRODUCTION_TAG}..`
echo ${LATEST_CHANGES}

