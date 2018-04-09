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
    sh 'docker run -d -t --name zalenium -p 4444:4444 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /tmp/videos:/home/seluser/videos \
        -v ${env.WORKSPACE}:/tmp/node/ \
        --privileged dosel/zalenium start';
    sh "docker run --name testbox -v ${env.WORKSPACE}:/tmp/qa_regression run.sh";
  }

  stage('Clean up') {
    sh 'docker rm -f testbox zalenium';
  }
}
