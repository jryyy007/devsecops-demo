pipeline {
    agent any

    // Global environment variables (set in Jenkins Configure System → Global properties)
    environment {
        NEXUS_URL = "${NEXUS_URL}"
        NEXUS_CREDENTIALS = "${NEXUS_CREDENTIALS}"
        NEXUS_REPO = "${NEXUS_REPO}"
        SONAR_TOKEN = "${SONAR_TOKEN}"
        EMAIL_CREDENTIALS = "${EMAIL_CREDENTIALS}"
        GITHUB_CREDENTIALS = "${GITHUB_CREDENTIALS}"
    }

    options {
        timestamps()           // adds timestamps to console output
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/jryyy007/devsecops-demo.git',
                    credentialsId: "${GITHUB_CREDENTIALS}"
            }
        }

        stage('Build') {
            steps {
                withMaven(maven: 'M3') { // 'M3' = Maven installation configured in Jenkins
                    sh 'mvn clean package'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') { // 'SonarQube' = Sonar server configured in Jenkins
                    sh "mvn sonar:sonar -Dsonar.login=${SONAR_TOKEN}"
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUS_URL}",
                    credentialsId: "${NEXUS_CREDENTIALS}",
                    repository: "${NEXUS_REPO}",
                    groupId: 'com.example',
                    artifactId: 'myapp',
                    version: '1.0-SNAPSHOT',
                    type: 'jar',
                    file: 'target/myapp-1.0-SNAPSHOT.jar'
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("myapp:1.0", ".")
                }
            }
        }

        stage('Email Notification') {
            steps {
                emailext(
                    to: 'jridim64@gmail.com',
                    subject: "${PROJECT_NAME} - Build # ${BUILD_NUMBER} - ${BUILD_STATUS}",
                    body: """Build completed for ${PROJECT_NAME}.
                        Check console output at ${BUILD_URL} to view details.""",
                    recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                    from: 'jridim64@gmail.com',
                    replyTo: 'jridim64@gmail.com',
                    smtpHost: 'smtp.gmail.com',
                    smtpPort: '587',
                    useSsl: false,
                    useTls: true,
                    credentialsId: "${EMAIL_CREDENTIALS}"
                )
            }
        }
    }

    post {
        success {
            echo 'Build, analysis, and deployment completed successfully!'
        }
        failure {
            echo 'Build failed! Check console output.'
        }
    }
}
