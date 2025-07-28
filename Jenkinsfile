pipeline {
  agent any

  environment {
    imageName = 'sivashankarrajendran/trend-app'
    version = 'latest'
  }

  stages {
    stage('Clone') {
      steps {
        git url: 'https://github.com/SivaShankarRajendran16/Trend.git'
      }
    }

    stage('Dockerize') {
      steps {
        sh 'docker build -t ${imageName}:${version} .'
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-credentials',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          echo 'Logging in to Docker Hub...'
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

          echo 'Pushing image to Docker Hub...'
          sh 'docker push ${imageName}:${version}'
        }
      }
    }
  }
}
