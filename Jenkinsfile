pipeline {
    agent any

    environment {
        ACR_NAME = "myacryashj"
        IMAGE_NAME = "myapi"
        RESOURCE_GROUP = "aks-rg"
        CLUSTER_NAME = "myAKSCluster"
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

        stage('Login to ACR') {
            steps {
                bat """
                echo Logging in to ACR: %ACR_NAME%
                az acr login --name %ACR_NAME%
                """
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def acrLoginServer = "${env.ACR_NAME}.azurecr.io"
                    bat """
                    echo Building Docker Image...
                    docker build -t %IMAGE_NAME% .
                    
                    echo Tagging Image...
                    docker tag %IMAGE_NAME% ${acrLoginServer}/%IMAGE_NAME%
                    
                    echo Pushing Image to ACR...
                    docker push ${acrLoginServer}/%IMAGE_NAME%
                    """
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat """
                echo Getting AKS Credentials...
                az aks get-credentials --resource-group %RESOURCE_GROUP% --name %CLUSTER_NAME% --overwrite-existing

                echo Applying Kubernetes Deployment...
                kubectl apply -f deployment.yaml
                """
            }
        }
    }
}
