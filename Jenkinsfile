#!groovy

def APPLICATION = params.application_name

node {
  stage('Launch Selenium Grid') {
    sh 'docker pull elgalu/selenium:latest';
    sh 'docker run -d -it --name elgalu -p 4444:24444 \
        -v /dev/shm:/dev/shm \
        -v /var/lib/jenkins/workspace/regression_tests:/tmp/qa_regression \
        --privileged elgalu/selenium'
  }

  stage('git checkout') {
    checkout scm
  }

  stage('Wait until Selenium Grid is ready') {
    sh 'grid_check.sh'
  }

  stage('Build testbox') {
    sh 'docker build -t testbox .'
  }

  stage('Execute tests') {
    try {
      sh "docker run --name testbox \
          -v /var/lib/jenkins/workspace/regression_tests:/tmp/qa_regression \
          --privileged testbox 'rake test $APPLICATION'"
    } catch(error) {
        println error
        currentBuild.result = 'FAILURE'
    }
  }

  stage('Clean up') {
    sh 'docker rm -f testbox elgalu';
  }
}
