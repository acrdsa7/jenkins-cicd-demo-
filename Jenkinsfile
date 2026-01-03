pipeline {

    agent any

    tools {
        maven 'MAVEN3.9'
        jdk 'JAVA17'
    }

    environment {
        IMAGE = "jenkins-cicd-demo"

        // 🔁 change these 2 for your VM
        REMOTE_USER = "opc"             // ubuntu / ec2-user / opc etc.
        REMOTE_HOST = "20.0.1.233"       // <-- your VM IP
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
                    docker tag $IMAGE:${BUILD_NUMBER} $USER/$IMAGE:${BUILD_NUMBER}
                    docker push $USER/$IMAGE:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy to Remote VM') {
            steps {
                sshagent (credentials: ['ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST '
                        echo $PASS | docker login -u $USER --password-stdin &&
                        docker rm -f demo-app || true &&
                        docker pull '$USER'/'$IMAGE':'${BUILD_NUMBER}' &&
                        docker run -d --name demo-app -p 8080:8080 '$USER'/'$IMAGE':'${BUILD_NUMBER}'
                    '
                    '''
                }
            }
        }
    }
}
