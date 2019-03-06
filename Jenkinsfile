#!groovy

def APPLICATION = params.application_name
def CONFIG_FILE = params.config_file
def SEL_GRID = params.application_name + '_' + 'selenium_grid'
def TEST_BOX = params.application_name + '_' + 'testbox'
def PORT = params.port

node {

  def PWD = pwd();

  stage('git checkout') {
    checkout scm
  }

  stage('Launch Selenium Grid') {
    try {
      sh "docker rm -f ${SEL_GRID}"
    } catch(err) {
      print err
    }

    sh 'docker pull elgalu/selenium';
    sh 'docker pull dosel/zalenium';

    sh "docker run --restart=unless-stopped \
        -d -it --name ${SEL_GRID} -p ${PORT} \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /tmp/videos:/home/seluser/videos \
        -v ${PWD}:/tmp/node/tmp/qa_regression \
        --privileged dosel/zalenium start"
  }

  stage('Check Selenium health') {
    sh "./script/grid_check.sh ${PORT.split(':')[0]}"
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
          --privileged testbox 'bundle install && rake test $APPLICATION'"
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
