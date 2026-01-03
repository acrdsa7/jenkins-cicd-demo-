pipeline {

    agent any

    tools {
        maven 'MAVEN3.9'
        jdk 'JAVA17'
    }

    environment {
        IMAGE = "jenkins-cicd-demo"
        REMOTE_USER = "opc"
        REMOTE_HOST = "20.0.1.233"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git(
                    url: 'https://github.com/acrdsa7/jenkins-cicd-demo-.git',
                    branch: 'main'
                )
            }
        }

        stage('Maven Build & Test') {
            steps {
                sh 'mvn clean package -DskipTests=false'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE:${BUILD_NUMBER} .'
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                        echo $PASS | docker login -u $USER --password-stdin

                        docker tag jenkins-cicd-demo:${BUILD_NUMBER} $USER/jenkins-cicd-demo:${BUILD_NUMBER}
                        docker tag jenkins-cicd-demo:${BUILD_NUMBER} $USER/jenkins-cicd-demo:latest

                        docker push $USER/jenkins-cicd-demo:${BUILD_NUMBER}
                        docker push $USER/jenkins-cicd-demo:latest
                    '''
                }
            }
        }

        stage('Deploy to Remote VM') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sshagent (credentials: ['ssh-key']) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no opc@20.0.1.233 "
                            echo '$DOCKER_PASS' | docker login -u '$DOCKER_USER' --password-stdin &&
                            docker rm -f demo-app || true &&
                            docker pull $DOCKER_USER/jenkins-cicd-demo:latest &&
                            docker run -d --name demo-app -p 8080:8080 $DOCKER_USER/jenkins-cicd-demo:latest
                        "
                        '''
                    }
                }
            }
        }
    }
}
