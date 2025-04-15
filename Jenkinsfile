pipeline {
  agent any

  environment {
    IMAGE_NAME = 'myapi'
  }

  stages {
    stage('Terraform - Provision Infrastructure') {
      steps {
        dir('terraform') {
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Get ACR Login Server') {
      steps {
        script {
          def output = sh(script: 'terraform -chdir=terraform output -raw acr_login_server', returnStdout: true).trim()
          env.ACR_LOGIN_SERVER = output
        }
      }
    }

    stage('Docker Build & Push') {
      steps {
        script {
          sh 'az acr login --name ${ACR_LOGIN_SERVER.split("\\.")[0]}'
          sh "docker build -t ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest -f Dockerfile ."
          sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest"
        }
      }
    }

    stage('Deploy to AKS') {
      steps {
        script {
          sh 'az aks get-credentials --resource-group aks-rg --name myAKSCluster'
          sh "sed 's|<ACR_LOGIN_SERVER>|${ACR_LOGIN_SERVER}|' deployment.yaml | kubectl apply -f -"
        }
      }
    }
  }
}
