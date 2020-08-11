#!/usr/bin/env bash
set -e

if [[ $TRAVIS_BRANCH == $DEV_BRANCH ]]; then
    echo "Pull Request Build is targetting ${DEV_BRANCH}. Check if all commits have prefixes."
    TOTAL_COMMITS=$(git log origin/$TRAVIS_BRANCH..HEAD --oneline | wc -l)
    VALID_COMMITS=$(git log origin/$TRAVIS_BRANCH..HEAD --format='%s' | grep -E "^(Merge|(fix|feat|BREAKING CHANGE|chore|docs|style|refactor|perf|test|improvement|build)(.+)?:) " | wc -l)
    echo "${VALID_COMMITS} out of ${TOTAL_COMMITS} commits follows Conventional Commit Specification or is a merge commit."

    if [[ $TOTAL_COMMITS == 0 ]]; then
        echo "Cannot determine the difference in commits between ${TRAVIS_PULL_REQUEST_BRANCH} branch and ${TRAVIS_BRANCH} branch"
        exit 1
    fi

    if [[ $VALID_COMMITS != $TOTAL_COMMITS ]]; then
        echo "Some commits does not follow the Conventional Commit Specification. Please make corrections and try again."
        exit 1
    fi
else
    echo "Pull Request Build is targeting ${PROD_BRANCH}. Check if at least one commit has a prefix."
    PREFIXED_COMMITS=$(git log origin/$TRAVIS_BRANCH..HEAD --format='%s' | grep -E "^(fix|feat|BREAKING CHANGE|chore|docs|style|refactor|perf|test|improvement|build)(.+)?: " | wc -l)
    if [[ $PREFIXED_COMMITS -lt 1 ]]; then
        echo "No commit follows the Conventional Commit Specification. Please make corrections and try again."
        exit 1
    fi
fi

echo "Commits are looking good! Moving on."
