#!/usr/bin/env bash
set -e

if [[ $(git log HEAD~1..HEAD --format=%s | grep "chore(release): ") == "" ]]; then
    git checkout -- .
    git checkout $TRAVIS_PULL_REQUEST_BRANCH

    echo "Attempting to sync ${TRAVIS_PULL_REQUEST_BRANCH} branch with latest of ${TRAVIS_BRANCH} branch."
    git merge --no-edit origin/$TRAVIS_BRANCH

    if [[ $(git ls-files -u | wc -l) -gt 0 ]]; then
        echo "Cannot automatically merge ${TRAVIS_PULL_REQUEST_BRANCH} branch with latest of ${TRAVIS_BRANCH} branch"
        exit 1
    fi

    if [[ ! -z $UPDATE_DEPENDENCIES ]]; then
        echo "Running '${UPDATE_DEPENDENCIES}' before bumping version"
        node $DEVOPS_SCRIPT_DIR/update_linked_dependencies.js
        git add .
    fi
    
    if [[ ! -z $BEFORE_VERSION_BUMP ]]; then
        echo "Running '${BEFORE_VERSION_BUMP}' before bumping version"
        $BEFORE_VERSION_BUMP
        git add .
    fi

    standard-version --skip.tag
    git push ${REMOTE:-origin} $TRAVIS_PULL_REQUEST_BRANCH
else
    echo "Version bump already done. Skipping..."
fi
