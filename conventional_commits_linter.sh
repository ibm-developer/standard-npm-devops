#!/usr/bin/env bash
set -ev

if [ $TRAVIS_BRANCH = $DEV_BRANCH ]; then
    echo "Pull Request Build is targetting ${DEV_BRANCH}. Check if all commits have prefixes."
    TOTAL_COMMITS=$(git log "${TRAVIS_BRANCH}..${TRAVIS_PULL_REQUEST_BRANCH}" --oneline | wc -l)
    VALID_COMMITS=$(git log "${TRAVIS_BRANCH}..${TRAVIS_PULL_REQUEST_BRANCH}" --format='%s' | grep -E "^(Merge|(fix|feat|BREAKING CHANGE|chore|docs|style|refactor|perf|test|improvement)(.+)?:) " | wc -l)
    echo "${VALID_COMMITS} out of ${TOTAL_COMMITS} commits follows Conventional Commit Specification or is a merge commit."

    if [ $VALID_COMMITS -ne $TOTAL_COMMITS ]; then
        echo "Some commits does not follow the Conventional Commit Specification. Please make corrections and try again."
        exit 1
    fi
else
    echo "Pull Request Build is targetting ${PROD_BRANCH}. Check if at least one commit has a prefix."
    PREFIXED_COMMITS=$(git log master..develop --format='%s' | grep -E "^(fix|feat|BREAKING CHANGE|chore|docs|style|refactor|perf|test|improvement)(.+)?: " | wc -l)
    if [ $PREFIXED_COMMITS -lt 1 ]; then
        echo "No commit follows the Conventional Commit Specification. Please make corrections and try again."
        exit 1
    fi
fi

echo "Commits are looking good! Moving on."
