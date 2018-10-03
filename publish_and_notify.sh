#!/usr/bin/env bash
set -e

echo "Add release in git"
git fetch origin $TRAVIS_BRANCH
git checkout $TRAVIS_BRANCH
standard-version --skip.bump --skip.changelog --skip.commit
git push ${REMOTE:-origin} --tags

echo "Publish to NPM"
npm publish

if [[ -v $SLACK_NOTIFICATION_PATH && -v $SLACK_WEBHOOK ]]; then
    echo "Slack notification setting present. Proceed to generate Changelog notification"
    HTML=$(markdown CHANGELOG.md)
    PKG_NAME=`node -e "console.log(require('./package.json').name);"`
    PKG_VER=`node -e "console.log(require('./package.json').version);"`
    node $SLACK_NOTIFICATION_PATH --html "$HTML" --name "$PKG_NAME" --api "$SLACK_WEBHOOK" --v "$PKG_VER"
fi
