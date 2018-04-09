#!groovy

node{
  sh 'git --no-pager show -s --format="%an -- %ae" | head -1 > committerInfo.txt'
}

def APPLICATION = params.application_name

node {
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

  stage('Launch Zalenium') {
    sh 'docker run --rm -ti --name zalenium -p 4444:4444' \
       '-v /var/run/docker.sock:/var/run/docker.sock' \
       '-v /tmp/videos:/home/seluser/videos' \
       '-v /tmp/qa_regression:/tmp/node/tmp/qa_regression' \
       '--privileged dosel/zalenium start'
  }

  stage('Test') {
    sh "docker run --name testbox -d -it --privileged testbox 'rake test ${APPLICATION}'"
  }

  stage('Clean up') {
    sh 'docker rm -f testbox zalenium';
  }
}
