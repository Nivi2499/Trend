pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'nivi99/trend-app'
        AWS_REGION = 'ap-southeast-2'
        EKS_CLUSTER = 'brain-tasks-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
                    kubectl set image deployment/trend-app trend-app=${DOCKER_IMAGE}:${BUILD_NUMBER} -n trend
                    kubectl rollout status deployment/trend-app -n trend
                '''
            }
        }
    }
}