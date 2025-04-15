pipeline {
  agent any

  environment {
    IMAGE_NAME = 'myapi'
  }

  stages {
    stage('Terraform - Provision Infrastructure') {
      steps {
        dir('terraform') {
          bat 'terraform init'
          bat 'terraform apply -auto-approve'
        }
      }
    }

    stage('Get ACR Login Server') {
      steps {
        script {
          def output = bat(script: 'terraform -chdir=terraform output -raw acr_login_server', returnStdout: true).trim()
          env.ACR_LOGIN_SERVER = output
        }
      }
    }

    stage('Docker Build & Push') {
      steps {
        script {
          def acrName = env.ACR_LOGIN_SERVER.tokenize('.')[0]

          bat "az acr login --name ${acrName}"
          bat "docker build -t ${env.ACR_LOGIN_SERVER}/${env.IMAGE_NAME}:latest -f Dockerfile ."
          bat "docker push ${env.ACR_LOGIN_SERVER}/${env.IMAGE_NAME}:latest"
        }
      }
    }

    stage('Deploy to AKS') {
      steps {
        script {
          bat 'az aks get-credentials --resource-group aks-rg --name myAKSCluster'

          // Create a temp file for the updated deployment.yaml
          writeFile file: 'updated-deployment.yaml', text: readFile('deployment.yaml')
            .replaceAll('<ACR_LOGIN_SERVER>', env.ACR_LOGIN_SERVER)

          bat 'kubectl apply -f updated-deployment.yaml'
        }
      }
    }
  }
}
