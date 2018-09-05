#!/usr/bin/env bash
set -ev

echo "Checking if a new version update is required ..."
PKG_NAME=`node -e "console.log(require('./package.json').name);"`
export PKG_VER=`node -e "console.log(require('./package.json').version);"`
export NPM_VER=`npm show $PKG_NAME version`
echo "$PKG_NAME : version = $PKG_VER, version on npm = $NPM_VER"

if [ $TRAVIS_BRANCH = "master" ]; then
    echo "Build targetting master - checking if this is a PR or not"
    if [[ "${TRAVIS_PULL_REQUEST}" = "false" ]]; then
        echo "This is a build on master, let's publish!"
        npm publish
        if [[ -v $SLACK_NOTIFICATION_PATH ]]
            HTML=$(markdown CHANGELOG.md)
            node $SLACK_NOTIFICATION_PATH --html "$HTML" --name "$PKG_NAME" --api "$SLACK_WEBHOOK" --v "$PKG_VER"
        fi
    else
        ./update_package_version.sh
    fi
fi
