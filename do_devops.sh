#!/usr/bin/env bash
set -e

if [[ -z $NPM_TOKEN ]]; then
    echo NPM_TOKEN is required.
fi

if [[ -z $DEVOPS_SCRIPT_DIR ]]; then
    echo DEVOPS_SCRIPT_DIR is required.
    exit 1
fi

if [[ -z $DEV_BRANCH ]]; then
    echo DEV_BRANCH is required.
    exit 1
fi

if [[ -z $PROD_BRANCH ]]; then
    echo PROD_BRANCH is required.
    exit 1
fi

if [[ -z $GITHUB_TOKEN ]]; then
    echo GITHUB_TOKEN is required.
    exit 1
fi

GIT_URL=$(git config remote.origin.url)
if [[ ${GIT_URL:0:8} == "https://" ]]; then
    export REMOTE=bot
    git remote add $REMOTE "${GIT_URL:0:8}${GITHUB_TOKEN}@${GIT_URL:8}"
fi

# Setting up hub
git config --global --add hub.host $(echo ${GIT_URL} | grep -Po "(?<=@).+\..+(?=:)|(?<=https:\/\/).+\..+(?=\/.+\/)")

# Settings to fetch origin
git config remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git config --add remote.origin.fetch +refs/tags/*:refs/tags/*

if [[ "${TRAVIS_PULL_REQUEST}" != "false" ]]; then
    echo "Current build is a Pull Request build."
    echo "Checking if the commits meets the Conventional Commits Specification."
    git fetch
    $DEVOPS_SCRIPT_DIR/conventional_commits_linter.sh

    if [[ $TRAVIS_BRANCH == $PROD_BRANCH ]]; then
        echo "The Pull Request is against ${PROD_BRANCH} branch. Proceed to update NPM package version."
        $DEVOPS_SCRIPT_DIR/sync_bump_version_and_push.sh
    else
        echo "Making sure ${TRAVIS_PULL_REQUEST_BRANCH} branch is in sync with ${TRAVIS_BRANCH} branch."
        git fetch origin $TRAVIS_PULL_REQUEST_BRANCH
        $DEVOPS_SCRIPT_DIR/check_branch_sync.sh

        echo "Checking if there is an outstanding PR to ${PROD_BRANCH} branch from ${TRAVIS_BRANCH} branch."
        $DEVOPS_SCRIPT_DIR/check_pr.sh
    fi
else
    if [[ $TRAVIS_BRANCH == $PROD_BRANCH ]]; then
        echo "Build is a ${PROD_BRANCH} branch build, let's publish and maybe notify."
        $DEVOPS_SCRIPT_DIR/publish_and_notify.sh
    else
        echo "Nothing to do on a non-${PROD_BRANCH} branch build."
    fi
fi

if [[ ! -z $REMOTE ]]; then
    git remote remove $REMOTE
fi

echo "Everything looks good! Thank you for using Standard NPM DevOps. Have a nice day!"
