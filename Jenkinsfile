pipeline {
    agent any

    environment {
        AWS_REG = 'ap-northeast-1'
        // Add other env vars here if needed
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/sujithchandran1/Boutique_App.git'
            }
        }

        stage('Configure & Build') {
            steps {
                withCredentials([aws(credentialsId: 'aws-cred')]) {
                    sh """
                    # Setup Kubeconfig
                    aws eks update-kubeconfig --region ${AWS_REG} --name demo-cluster
                    
                    # Run your build script
                    chmod +x Microservices/docker_image_buid_push.sh
                    ./Microservices/docker_image_buid_push.sh
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                // IMPORTANT: kubectl needs the AWS keys to authenticate with the EKS cluster
                withCredentials([aws(credentialsId: 'aws-cred')]) {
                    sh "kubectl apply -f Microservices/kubernetes-manifests"
                }
            }
        }

        stage('Verify') {
            steps {
                withCredentials([aws(credentialsId: 'aws-cred')]) {
                    sh "kubectl get pods"
                }
            }
        }
    }
    // Optional - to delete the unwanted cache.
    post {
        always {
            // Cleanup to prevent the "No Space" error from coming back
            sh 'docker system prune -f'
            cleanWs()
        }
    }
}