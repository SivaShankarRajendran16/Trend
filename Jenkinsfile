pipeline {
  agent any

  environment {
    imageName = 'sivashankarrajendran/trend-app'
    version = 'latest'
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/SivaShankarRajendran16/Trend.git'
      }
    }

    stage('Dockerize') {
      steps {
        script {
          echo "Building Docker image..."
          sh 'docker build -t $imageName:$version .'
        }
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-credentials',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          script {
            echo "Logging in to Docker Hub..."
            sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"

            echo "Pushing image to Docker Hub..."
            sh "docker push $imageName:$version"

            echo "Docker push completed."
          }
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline execution completed."
    }
    failure {
      echo "Build failed. Please check the logs."
    }
  }
}
