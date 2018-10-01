#!/usr/bin/env bash
set -e

git fetch origin $TRAVIS_PULL_REQUEST_BRANCH
git checkout $TRAVIS_PULL_REQUEST_BRANCH

standard-version --skip.tag
export HUB_VERBOSE=true
hub push origin $TRAVIS_PULL_REQUEST_BRANCH
