pipeline {
  agent any
  stages {
    stages {
    stage('Clone') {
      steps { git url: 'https://github.com/SivaShankarRajendran16/Trend.git' }
    }
    stage('Build & Dockerize') {
      steps {
        sh 'npm install'
        sh 'npm run build'
        sh 'docker build -t sivashankarrajendran/trend-app:latest .'
      }
    }
    stage("Push to DockerHub") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    echo "Logging in to Docker Hub..."
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    
                    echo "Pushing image to Docker Hub..."
                    sh "docker push ${imageName}:${version}"
                
                }
            }
        }
    stage('Deploy to Kubernetes') {
      steps {
        sh 'kubectl apply -f kubernetes/deployment.yaml'
        sh 'kubectl apply -f kubernetes/service.yaml'
      }
    }
  }
}
