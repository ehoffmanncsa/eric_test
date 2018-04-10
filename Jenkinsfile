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
    'Build Testbox': {
      stage('Build Testbox') {
        sh 'docker build -t testbox .'
      }
    }
  )

  stage('Test') {
    sh 'docker run -d --name=elgalu -p 4444:24444 \
        -e NOVNC=true  -e VNC_PASSWORD=secure.123 \
        -e MAX_INSTANCES=20 -e MAX_SESSIONS=20 --shm-size=1g \
        -v /var/lib/jenkins/workspace/regression_tests:/home/seluser \
        elgalu/selenium';
    sh "docker run --name testbox --privileged testbox 'rake test $APPLICATION'"
  }

  stage('Clean up') {
    sh 'docker rm -f testbox elgalu';
  }
}
