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

    stage('Docker Build') {
      steps {
        script {
          echo "Building Docker image..."
          sh 'docker build -t $imageName:$version .'
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
