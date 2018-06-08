#!groovy

def APPLICATION = params.application_name
def CONFIG_FILE = params.config_file
def SEL_GRID = params.application_name + '_' + 'selenium_grid'
def TEST_BOX = params.application_name + '_' + 'testbox'

node {

  def PWD = pwd();

  stage('git checkout') {
    checkout scm
  }

  stage('Launch Selenium Grid') {
    try {
      sh 'docker rm -f elgalu'
    } catch(err) {
      print err
    }

    sh 'docker pull elgalu/selenium:latest';

    sh "docker run --restart=unless-stopped \
        -d -it --name ${SEL_GRID} -p 4444:24444 \
        -v /dev/shm:/dev/shm \
        -v ${PWD}:/tmp/qa_regression \
        -e MAX_INSTANCES=20 -e MAX_SESSIONS=20 \
        --privileged elgalu/selenium"
  }

  stage('Check Selenium health') {
    sh './script/grid_check.sh'
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
          --privileged testbox 'bundle install && rake test $APPLICATION'"
    } catch(error) {
        println error
        currentBuild.result = 'FAILURE'
    }
  }

  stage('Clean up') {
    sh "docker rm -f ${SEL_GRID} ${TEST_BOX}";
  }
}
