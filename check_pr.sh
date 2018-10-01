#!/usr/bin/env bash
set -e

if [[ $(hub pr list -h "${TRAVIS_BRANCH}" -b "${PROD_BRANCH}") != "" ]]; then
    echo "${TRAVIS_BRANCH} branch currently has a Pull Request against ${PROD_BRANCH} branch!"
    exit 1
fi