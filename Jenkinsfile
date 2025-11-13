pipeline {
    agent any

    environment {
        // Jenkins Global Variables (Configure in Manage Jenkins -> Configure System)
        NEXUS_URL = 'http://localhost:8081'
        NEXUS_CREDENTIALS = 'nexus-login'
        NEXUS_REPO = 'maven-releases'
        SONAR_TOKEN = credentials('sonar-token')
        PROJECT_NAME = 'myapp'
    }

    tools {
        // Maven version configured in Jenkins
        maven 'MAVEN3'
        // Java version configured in Jenkins
        jdk 'JDK21'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jryyy007/devsecops-demo.git',
                    credentialsId: 'github-cred'
            }
        }

        stage('Build') {
            steps {
                script {
                    sh 'mvn clean package'
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_HOST_URL = 'http://localhost:9000/'
                SONAR_LOGIN = "${SONAR_TOKEN}"
            }
            steps {
                script {
                    sh "mvn sonar:sonar -Dsonar.projectKey=${PROJECT_NAME} -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_TOKEN}"
                }
            }
        }

        stage('Upload to Nexus') {
    steps {
        nexusArtifactUploader(
            nexusVersion: 'nexus3',
            protocol: 'http',
            nexusUrl: "${NEXUS_URL}",
            groupId: 'com.example',          // Moved to top level
            version: '1.0-SNAPSHOT',         // Moved to top level (but see note below on snapshots)
            repository: "${NEXUS_REPO}",
            credentialsId: "${NEXUS_CREDENTIALS}",
            artifacts: [
                [artifactId: 'myapp',
                 type: 'jar',
                 classifier: '',             // Optional; empty if no classifier
                 file: 'target/myapp-1.0-SNAPSHOT.jar']
            ]
        )
    }
}

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t myapp:latest ."
                }
            }
        }

        stage('Publish Docker Image (Optional)') {
            steps {
                echo 'If you want, push to local Docker registry or Docker Hub here'
            }
        }
    }

    post {
        success {
            emailext(
                to: 'jridim64@gmail.com',
                subject: "${PROJECT_NAME} - Build # ${BUILD_NUMBER} - SUCCESS",
                body: """Build SUCCESSFUL for ${PROJECT_NAME}.
Check console output at ${BUILD_URL}."""
            )
        }
        failure {
            emailext(
                to: 'jridim64@gmail.com',
                subject: "${PROJECT_NAME} - Build # ${BUILD_NUMBER} - FAILURE",
                body: """Build FAILED for ${PROJECT_NAME}.
Check console output at ${BUILD_URL}."""
            )
        }
    }
}

