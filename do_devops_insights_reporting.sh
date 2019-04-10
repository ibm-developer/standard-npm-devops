# assumes LOGICAL_APP_NAME , GIT_URL , and IBM_CLOUD_API_KEY defined in .travis.yml
#  and normal travis env variables
# exports below are further idra env variables

export ORGANIZATION_NAME=devops-insights
export TOOLCHAIN_ID=613b358f-4e81-441d-83a7-0d1cba95f02e
export BUILD_NUMBER=`date '+%Y-%m-%d %H:%M:%S'`
export IDRA_DEBUG=true
export DEVOPS_REPORT_DIR=$TRAVIS_BUILD_DIR/devops_insights/

cd $TRAVIS_BUILD_DIR
npm i -g grunt-idra3
mkdir -p $DEVOPS_REPORT_DIR
nyc report --reporter=cobertura --report-dir=$DEVOPS_REPORT_DIR
mocha --reporter=json > $DEVOPS_REPORT_DIR/mocha-unittest.json
idra --publishtestresult --filelocation=$DEVOPS_REPORT_DIR/cobertura-coverage.xml \
	--env=$TRAVIS_PULL_REQUEST_BRANCH --type=code --drilldownurl=$TRAVIS_JOB_WEB_URL
idra --publishtestresult --filelocation=$DEVOPS_REPORT_DIR/mocha-unittest.json \
	--env=$TRAVIS_PULL_REQUEST_BRANCH --type=unittest --drilldownurl=$TRAVIS_JOB_WEB_URL
idra --evaluategate  --policy=devex-languages-base --forcedecision=true
POLICY_EXIT=$?

if [ $POLICY_EXIT -eq 0 ]; then
	idra --publishbuildrecord  --branch=$TRAVIS_PULL_REQUEST_BRANCH --repositoryurl=$GIT_URL --commitid=$TRAVIS_COMMIT --status="pass"
else
	idra --publishbuildrecord  --branch=$TRAVIS_PULL_REQUEST_BRANCH --repositoryurl=$GIT_URL --commitid=$TRAVIS_COMMIT --status="fail"
fi

exit $POLICY_EXIT