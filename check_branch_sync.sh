#!/usr/bin/env bash
set -e

if [[ $(git log "origin/${TRAVIS_PULL_REQUEST_BRANCH}..origin/${TRAVIS_BRANCH}" --format='%h' | wc -l) -gt 0 ]]; then
    echo "${TRAVIS_PULL_REQUEST_BRANCH} branch is out of sync with ${TRAVIS_BRANCH} branch"
    exit 1
fi

echo "${TRAVIS_PULL_REQUEST_BRANCH} branch is up to date with ${TRAVIS_BRANCH} branch"