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

  stage('Build testbox') {
    sh 'docker build -t testbox .'
  }

  stage('Execute tests') {
    sh "docker run --name testbox \
        -v /var/lib/jenkins/workspace/regression_tests:/tmp/qa_regression \
        --privileged testbox 'rake test $APPLICATION'"
  }

  try {
    stage('Execute tests') {
      node {
       def exec = build job:'Execute tests', propagate: false
       result = exec.result
       if (result.equals('SUCCESS')) {
       } else {
          error 'FAIL';
          sh "exit 1" // this fails the stage
       }
      }
    }
  } catch (e) {
      currentBuild.result = 'FAILURE'
      result = 'FAIL' // make sure other exceptions are recorded as failure too
  }

  stage('Clean up') {
    sh 'docker rm -f testbox elgalu';
  }
}
