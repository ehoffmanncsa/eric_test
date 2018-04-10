#!groovy

def APPLICATION = params.application_name

node {
  stage('checkout') {
    checkout scm
  }

  label('Testing')
  parallel(
    'Pull elgalu/selenium': {
      stage('Pull Elgalu') {
        sh 'docker pull elgalu/selenium:latest'
      }
    },
    'Pull dosel/zalenium': {
      stage('Pull Zalenium') {
        sh 'docker pull dosel/zalenium:latest'
      }
    },
    'Build Testbox': {
      stage('Build Testbox') {
        sh 'docker build -t testbox .'
      }
    }
  )

  stage('Test') {
    sh 'docker run -d -t --name elgalu -p 4444:24444 \
        -v /dev/shm:/dev/shm \
        -v /var/lib/jenkins/workspace/regression_tests:/home/seluser \
        --privileged elgalu/selenium';
    sh "docker run --name testbox --privileged testbox 'rake test $APPLICATION'"
  }

  stage('Clean up') {
    sh 'docker rm -f testbox elgalu';
  }
}
