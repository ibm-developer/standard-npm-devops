#!/usr/bin/env bash
set -ev

if [[ "${TRAVIS_PULL_REQUEST}" = "true" ]]; then
    echo "Current build is a Pull Request build. Check if the commits meets the Conventional Commits Specification."
    ./conventional_commits_linter.sh

    if [ $TRAVIS_BRANCH = $PROD_BRANCH ]; then
        echo "The Pull Request is against ${PROD_BRANCH} branch. Proceed to update NPM package version."
        ./update_package_version.sh
    fi
else
    if [ $TRAVIS_BRANCH = $PROD_BRANCH ]; then
        echo "Build is a ${PROD_BRANCH} branch build, let's publish and maybe notify."
        ./publish_and_notify.sh
    else
        echo "Nothing to do on a non-${PROD_BRANCH} branch build."
    fi
fi

echo "Everything looks good! Thank you for using Standard NPM DevOps. Have a nice day!"
