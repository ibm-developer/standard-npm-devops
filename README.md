# standard-npm-devops
Scripts for npm standard version updates w/ node repositories.

## Setting Up Github Bot User
Create Personal Access Token
1. Skip this step if a github token is already available.
1. Go to https://github.com/settings/tokens/new while logged in to the Bot User.
1. Set a reasonable and recognizable `Token description`.
1. Check `public_repo` under `Select scopes`.
1. Generate token.
1. Copy the token highlighted with green background before it disappears.
1. Paste the token somewhere safe but readable.

Make Bot User Admin
1. Navigate to the repository for the npm package requiring devOps.
1. Add Bot User as an Admin.

## Setting Up NPM Bot User
Create Access Token
1. Skip if NPM token is already available.
1. Log into NPM registry as bot user.
1. Click profile avatar, then click `Tokens`
1. Click `Create New Token`
1. Select `Read and Publish` then `Create Token`
1. Copy the token in box before it disappears.
1. Paste the token somewhere safe but readable.

## Setting Up Travis Application
Migrate Travis Integration to Github Application
1. Follow instructions on Travis

First-time Travis Application
1. Login to Org owner account
1. Go to https://github.com/marketplace/travis-ci#pricing-and-setup
1. Choose `Open Source`
1. Click `Install it for free`
1. Click `Complete order and begin installation`
1. Decide whether to pick and choose or include all repositories.

## Setting Up Coveralls Application


## Repository Setup
Setting Up Repository in Travis
1. Go to Settings
1. Add GITHUB_TOKEN and NPM_TOKEN as environment variables
1. Turn on `Auto cancel pull request builds`
1. For Github Enterprise, Add ssh key for bot user

Setting Up Merge Style
1. Navigate to Settings/Options
1. **DO NOT** check `Allow squash merging`
1. **DO NOT** check `Allow rebase merging`

Setting Up Branch Protection
1. Default Branch: `develop`
1. Branch protection rules: `master`
    - Require pull request reviews before merging
    - Require status checks to pass before merging
    - Status checks found in the last week for this repository: list shows up after first run
    - Require branches to be up to date before merging
    - Include administrators
1. Branch protection rules: `develop`
    - Require pull request reviews before merging
    - Require status checks to pass before merging
    - Status checks found in the last week for this repository: list shows up after first run
        - **DO NOT** require `Travis CI - Branch`
    - Require branches to be up to date before merging
    - **DO NOT**: Include administrators


Setting Up Repository for Travis
1. Add a `.travis.yml` with following information
    ```
    language: node_js
    node_js:
    - '8'
    before_install:
    - npm i -g makeshift && makeshift -r https://registry.npmjs.org
    - npm i -g standard-version
    before_script:
    - cd /tmp
    - wget https://github.com/github/hub/releases/download/v2.5.1/hub-linux-386-2.5.1.tgz
    - tar -xvzf hub-linux-386-2.5.1.tgz
    - mv hub-linux-386-2.5.1 hub
    - export PATH=${PATH}:/tmp/hub/bin
    - git clone -b master https://github.com/ibm-developer/standard-npm-devops.git
    - cd -
    script: npm test && npm run coveralls && /tmp/standard-npm-devops/do_devops.sh
    branches:
      only:
      - master
      - develop
    env:
      - DEV_BRANCH=develop PROD_BRANCH=master DEVOPS_SCRIPT_DIR="/tmp/standard-npm-devops"
    ```

## Slack Notification Setup
Travis CI Notification
1. Log into a Bot Account on Slack
1. Select `Customize Slack` under the desired workspace
1. Select `Configure Apps`
1. Add a Travis CI configuration
1. Follow the instructions for `Encrypting your credentials`

Changelog Notification
1. Find `Incoming Hooks` under `Custom Integrations`
1. Copy `Webhook URL` and add a environment variable in Travis called SLACK_WEBHOOK
1. Add the following in `.travis.yml`
    - Under `before_install`
        ```
        - npm i -g markdown-to-html
        ```
    - Under `before_script`
        ```
        - git clone -b master https://github.com/ibm-developer/changelog-generator-slack-notification.git
        - npm install changelog-generator-slack-notification
        ```
    - Under `env`: add to first entry
        `SLACK_NOTIFICATION_PATH="/tmp/changelog-generator-slack-notification"` so it becomes:
        ```
        - DEV_BRANCH=develop PROD_BRANCH=master DEVOPS_SCRIPT_DIR="/tmp/standard-npm-devops" SLACK_NOTIFICATION_PATH="/tmp/changelog-generator-slack-notification"
        ```

## Operations
Pull Request to `develop`
1. Make sure commits follows conventional commits standards. Merge commits are ok.
1. Make sure merging branch is in sync with `develop`
1. Make sure there are no open Pull Request from `develop` to master

Pull Request to `master`
1. Make sure to Pull Request from `develop`
1. Pull Request from other branches are tolerable in emergencies, but will result in `develop` branch needing admin intervention to sync.
1. Make sure there is at least one new commit that follows conventional commits standards.
1. Build will attempt to sync `master` and create a version release commit.

Publishing
1. `master` branch build will push new version tag to Github
1. `master` branch build will publish new version to NPM
