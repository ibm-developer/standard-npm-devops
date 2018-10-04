#!/usr/bin/env bash
set -e

if [[ $(git log HEAD~1..HEAD --format=%s | grep "chore(release): ") == "" ]]; then
    git fetch origin $TRAVIS_PULL_REQUEST_BRANCH
    git checkout $TRAVIS_PULL_REQUEST_BRANCH

    echo "Attempting to sync ${TRAVIS_PULL_REQUEST_BRANCH} branch with latest of ${TRAVIS_BRANCH} branch."
    git fetch origin $TRAVIS_BRANCH
    git merge origin/$TRAVIS_BRANCH

    if [[ $(git ls-files -u | wc -l) -gt 0 ]]; then
        echo "Cannot automatically merge ${TRAVIS_PULL_REQUEST_BRANCH} branch with latest of ${TRAVIS_BRANCH} branch"
        exit 1
    fi

    standard-version --skip.tag
    git push ${REMOTE:-origin} $TRAVIS_PULL_REQUEST_BRANCH
else
    echo "Version bump already done. Skipping..."
fi