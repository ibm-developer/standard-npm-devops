#!/usr/bin/env bash
set -e

if [[ -v $GITHUB_HOST ]]; then
    git config --global --add hub.host $GITHUB_HOST
fi

if [[ "${TRAVIS_PULL_REQUEST}" != "false" ]]; then
    echo "Current build is a Pull Request build."
    echo "Check if the commits meets the Conventional Commits Specification."
    git config remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
    git fetch origin $TRAVIS_BRANCH
    $DEVOPS_SCRIPT_DIR/conventional_commits_linter.sh

    echo "Check if there is an outstanding PR to ${PROD_BRANCH} branch from ${TRAVIS_BRANCH} branch."
    $DEVOPS_SCRIPT_DIR/check_pr.sh

    if [[ $TRAVIS_BRANCH == $PROD_BRANCH ]]; then
        echo "The Pull Request is against ${PROD_BRANCH} branch. Proceed to update NPM package version."
        $DEVOPS_SCRIPT_DIR/check_branch_sync.sh
        $DEVOPS_SCRIPT_DIR/bump_version_and_push.sh
    fi
else
    if [[ $TRAVIS_BRANCH == $PROD_BRANCH ]]; then
        echo "Build is a ${PROD_BRANCH} branch build, let's publish and maybe notify."
        $DEVOPS_SCRIPT_DIR/publish_and_notify.sh
    else
        echo "Nothing to do on a non-${PROD_BRANCH} branch build."
    fi
fi

echo "Everything looks good! Thank you for using Standard NPM DevOps. Have a nice day!"
