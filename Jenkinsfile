pipeline {
  agent any
  stages {
    stage('Clone') {
      steps { git url: '<your-github-repo-url>' }
    }
    stage('Build & Dockerize') {
      steps {
        sh 'npm install'
        sh 'npm run build'
        sh 'docker build -t <username>/trend-app:latest .'
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
