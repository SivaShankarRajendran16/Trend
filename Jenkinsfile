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
    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh 'echo $PASS | docker login -u $USER --password-stdin'
          sh 'docker push <username>/trend-app:latest'
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
