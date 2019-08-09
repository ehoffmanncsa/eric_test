#!groovy

def APPLICATION = params.application_name
def ENV_NAME = params.environment_name
def SEL_GRID = params.application_name + '_' + 'selenium_grid'
def TEST_BOX = params.application_name + '_' + 'testbox'
def PORT = params.port

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

  stage('Run setup') {
    sh "./script/setup.sh ${PORT.split(':')[0]}"
  }

  stage('Build testbox') {
    sh 'docker build -t testbox .'
  }

  stage('Execute tests') {
    try {
      sh "docker run --restart=unless-stopped \
          --name ${TEST_BOX} \
          -v ${PWD}:/tmp/qa_regression \
          -e ENV_NAME=${ENV_NAME} \
          -e PORT=${PORT} \
          --env-file .${ENV_NAME}-docker.env \
          --privileged testbox 'gem i bundler -v 1.17.3 && bundle i && rake test ${APPLICATION}'"
    } catch(error) {
        println error
        currentBuild.result = 'FAILURE'
    }
  }

  stage('Clean up') {
    sh "docker stop ${SEL_GRID}";
    sh "./script/container_check.sh";
    sh "docker rm -f ${TEST_BOX}";
  }
}
