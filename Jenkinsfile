#!groovy

def APPLICATION = params.application_name
def CONFIG_FILE = params.config_file
def SEL_GRID = params.application_name + '_' + 'selenium_grid'
def TEST_BOX = params.application_name + '_' + 'testbox'
def PORT = params.port
def HELPSCOUT_SECRET_KEY = params.helpscout_secret_key
def NCSA_HELPSCOUT_API_KEY = params.ncsa_helpscout_api_key
def NCSA_HELPSCOUT_ACCOUNT = params.ncsa_helpscout_account
def NCSA_PASS_API_KEY = params.ncsa_pass_api_key
def NCSA_PASS_ACCOUNT = params.ncsa_pass_account

node {

  def PWD = pwd();

  stage('Clone Repo') {
    checkout scm
  }

  stage('Launch Selenium Grid') {
    try {
      sh "./script/container_check.sh";
    } catch(err) {
      print err
    }

    sh 'docker pull elgalu/selenium';
    sh 'docker pull dosel/zalenium';

    sh "docker run --restart=unless-stopped \
        -d -it --name ${SEL_GRID} -p ${PORT} \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${PWD}:/tmp/node/tmp/qa_regression \
        --privileged dosel/zalenium start"
  }

  stage('Health Check') {
    sh "./script/setup_check.sh ${PORT.split(':')[0]}"
  }

  stage('Build testbox') {
    sh 'docker build -t testbox .'
  }

  stage('Execute tests') {
    try {
      sh "docker run --restart=unless-stopped \
          --name ${TEST_BOX} \
          -v ${PWD}:/tmp/qa_regression \
          -e CONFIG_FILE=${CONFIG_FILE} \
          -e PORT=${PORT} \
          -e HELPSCOUT_SECRET_KEY=${HELPSCOUT_SECRET_KEY} \
          -e NCSA_HELPSCOUT_API_KEY=${NCSA_HELPSCOUT_API_KEY} \
          -e NCSA_HELPSCOUT_ACCOUNT=${NCSA_HELPSCOUT_ACCOUNT} \
          -e NCSA_PASS_API_KEY=${NCSA_PASS_API_KEY} \
          -e NCSA_PASS_ACCOUNT=${NCSA_PASS_ACCOUNT} \
          --privileged testbox 'gem i bundler -v 1.17.3 && bundle i && rake test ${APPLICATION}'"
    } catch(error) {
        println error
        currentBuild.result = 'FAILURE'
    }
  }

  stage('Clean up') {
    sh "docker stop ${SEL_GRID}";
    echo 'Waiting 1 minutes for Selenium grid and dependents to completely stop before proceeding';
    sleep 60;

    sh "./script/container_check.sh";

    sh "docker rm -f ${TEST_BOX}";
  }
}
