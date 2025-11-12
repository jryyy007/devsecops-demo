// Jenkinsfile for DevSecOps Demo Project
// Author: You
// Purpose: CI/CD pipeline with Maven, Nexus, SonarQube, Docker, and Email notifications

pipeline {
    agent any

    environment {
        // Define all credentials stored in Jenkins
        NEXUS_CREDENTIALS = 'nexus-login'
        NEXUS_URL = 'http://localhost:8081'
        NEXUS_REPO = 'vprofile-release'

        SONAR_TOKEN = 'sonar-token'
        SONAR_URL = 'http://localhost:9000'

        EMAIL_CREDENTIALS = 'mail-cred'
        EMAIL_RECIPIENTS = 'jridim64@gmail.com'

        DOCKER_IMAGE_NAME = 'myapp-demo'
        DOCKER_TAG = 'latest'
    }

    options {
        // Keep build history short for local VM
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Abort builds that take too long
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out project from GitHub..."
                git branch: 'main',
                    url: 'https://github.com/jryyy007/devsecops-demo.git',
                    credentialsId: 'github-cred'
            }
        }

        stage('Build with Maven') {
            steps {
                echo "Building the project using Maven..."
                withMaven(maven: 'MAVEN3') {
                    sh 'mvn clean package'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube scan..."
                withSonarQubeEnv('sonar-server') {
                    sh """
                    sonar-scanner \
                      -Dsonar.projectKey=myapp \
                      -Dsonar.sources=src \
                      -Dsonar.host.url=${SONAR_URL} \
                      -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                echo "Uploading JAR artifact to Nexus..."
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUS_URL}",
                    credentialsId: "${NEXUS_CREDENTIALS}",
                    repository: "${NEXUS_REPO}",
                    artifacts: [[
                        groupId: 'com.example',              // matches pom.xml
                        artifactId: 'myapp',                 // matches pom.xml
                        version: '1.0-SNAPSHOT',             // matches pom.xml
                        classifier: '',
                        file: 'target/myapp-1.0-SNAPSHOT.jar',
                        type: 'jar'
                    ]]
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh """
                docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} .
                """
            }
        }

        stage('Push Docker Image (Optional Local Registry)') {
            steps {
                echo "Pushing Docker image to local registry (if exists)..."
                // For local testing, optional
                // sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} localhost:5000/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                // sh "docker push localhost:5000/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
            }
        }

    }

    post {
        success {
            echo "Build succeeded! Sending notification email..."
            mail bcc: '', body: """Project ${env.JOB_NAME} build #${env.BUILD_NUMBER} SUCCESS
            Check console output at ${env.BUILD_URL}""",
            cc: '', from: '', replyTo: '', subject: "SUCCESS: Build #${env.BUILD_NUMBER}",
            to: "${EMAIL_RECIPIENTS}"
        }
        failure {
            echo "Build failed! Sending notification email..."
            mail bcc: '', body: """Project ${env.JOB_NAME} build #${env.BUILD_NUMBER} FAILED
            Check console output at ${env.BUILD_URL}""",
            cc: '', from: '', replyTo: '', subject: "FAILURE: Build #${env.BUILD_NUMBER}",
            to: "${EMAIL_RECIPIENTS}"
        }
    }
}
