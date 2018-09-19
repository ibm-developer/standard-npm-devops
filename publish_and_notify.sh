#!/usr/bin/env bash
set -ev

echo "Publish to NPM"
npm publish

echo "Add release in git"
git remote rm origin
git remote add origin $GITHUB_URL_SECURED
hub push --follow-tags --set-upstream origin $TRAVIS_PULL_REQUEST_BRANCH

if [[ -v $SLACK_NOTIFICATION_PATH && -v $SLACK_WEBHOOK ]]
    echo "Slack notification setting present. Proceed to generate Changelog notification"
    HTML=$(markdown CHANGELOG.md)
    PKG_NAME=`node -e "console.log(require('./package.json').name);"`
    PKG_VER=`node -e "console.log(require('./package.json').version);"`
    node $SLACK_NOTIFICATION_PATH --html "$HTML" --name "$PKG_NAME" --api "$SLACK_WEBHOOK" --v "$PKG_VER"
fi
