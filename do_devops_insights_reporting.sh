# uses idra to report nyc mocha test results to toolchain
# assumes LOGICAL_APP_NAME , GIT_URL , IBM_CLOUD_API_KEY , ORGANIZATION_NAME , TOOLCHAIN_ID
#  are defined in .travis.yml global variables and normal travis env variables as well

export BUILD_NUMBER=`date '+%Y-%m-%d %H:%M:%S'`
export IDRA_DEBUG=true

if [ -z "$TRAVIS_BUILD_DIR" ]; then 
	echo "ERROR: devops insights must be run from travis build"
	exit 1
fi

if  [ -z "$LOGICAL_APP_NAME" ] || [ -z "$GIT_URL" ] || [ -z "$IBM_CLOUD_API_KEY" ] || \
	[ -z "$ORGANIZATION_NAME" ] || [ -z "$TOOLCHAIN_ID" ]; then 
	echo "ERROR: LOGICAL_APP_NAME, GIT_URL, IBM_CLOUD_API_KEY, ORGANIZATION_NAME, TOOLCHAIN_ID \
		must be defined in .travis.yml global variables"
	exit 1
fi

cd $TRAVIS_BUILD_DIR
npm i -g grunt-idra3
mkdir -p $DEVOPS_REPORT_DIR

nyc report --reporter=cobertura --report-dir=$DEVOPS_REPORT_DIR
mocha --reporter=json > $DEVOPS_REPORT_DIR/mocha-unittest.json

idra --publishtestresult --filelocation=$DEVOPS_REPORT_DIR/cobertura-coverage.xml \
	--env=$TRAVIS_BRANCH --type=code --drilldownurl=$TRAVIS_JOB_WEB_URL
idra --publishtestresult --filelocation=$DEVOPS_REPORT_DIR/mocha-unittest.json \
	--env=$TRAVIS_BRANCH --type=unittest --drilldownurl=$TRAVIS_JOB_WEB_URL
idra --evaluategate  --policy=devex-languages-base --forcedecision=true

POLICY_EXIT=$?

if [ "$POLICY_EXIT" -eq 0 ]; then
	idra --publishbuildrecord  --branch=$TRAVIS_BRANCH --repositoryurl=$GIT_URL \
		--commitid=$TRAVIS_COMMIT --status="pass"
else
	idra --publishbuildrecord  --branch=$TRAVIS_BRANCH --repositoryurl=$GIT_URL \
		--commitid=$TRAVIS_COMMIT --status="fail"
fi

exit $POLICY_EXIT
