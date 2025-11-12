pipeline {
    agent any

    environment {
        // SonarQube server configured in Jenkins
        SONARQUBE = 'sonar-server'
        // Nexus credentials ID stored in Jenkins
        NEXUS_CRED = 'nexuslogin'
        NEXUS_URL = 'http://localhost:8081/repository/vprofile-release/'
        // Docker image name
        IMAGE_NAME = 'myapp:latest'
        // Gmail credentials ID
        GMAIL_CRED = 'mail-cred'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jryyy007/devsecops-demo.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(SONARQUBE) {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dp-check'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}"
            }
        }

        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[
                    artifactId: 'myapp',
                    classifier: '',
                    file: 'target/myapp-1.0-SNAPSHOT.jar',
                    type: 'jar'
                ]],
                credentialsId: "${NEXUS_CRED}",
                groupId: 'com.example',
                nexusUrl: "${NEXUS_URL}",
                repository: 'vprofile-release',
                version: '1.0-SNAPSHOT'
            }
        }
    }

    post {
        success {
            emailext (
                subject: "SUCCESS: Build #${BUILD_NUMBER} of ${JOB_NAME}",
                body: "Build succeeded!\nCheck console output at ${BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                to: 'your-email@gmail.com',
                replyTo: 'your-email@gmail.com',
                from: 'your-email@gmail.com'
            )
        }
        failure {
            emailext (
                subject: "FAILURE: Build #${BUILD_NUMBER} of ${JOB_NAME}",
                body: "Build failed!\nCheck console output at ${BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                to: 'your-email@gmail.com',
                replyTo: 'your-email@gmail.com',
                from: 'your-email@gmail.com'
            )
        }
    }
}
