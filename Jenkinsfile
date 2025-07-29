pipeline {
  agent any

  environment {
    imageName = 'sivashankarrajendran/trend-app'
    version = 'latest'
    AWS_REGION = 'ap-south-1'
    CLUSTER_NAME = 'trend'
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/SivaShankarRajendran16/Trend.git'
      }
    }

    stage('Docker Build') {
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

    stage('Deploy to EKS') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-creds'
        ]]) {
          script {
            echo "Updating kubeconfig..."
            sh "aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME"

            echo "Deploying to EKS..."
            sh '''
              kubectl apply -f kubernetes/deployment.yaml
              kubectl apply -f kubernetes/service.yaml
            '''
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
      echo "Build or deployment failed. Check logs."
    }
  }
}
