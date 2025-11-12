pipeline {
    agent any

    environment {
        // Jenkins credentials IDs
        GIT_CREDENTIALS = 'github-cred'      // GitHub username/token
        NEXUS_CREDENTIALS = 'nexus-login'    // Nexus username/password
        SONAR_TOKEN = 'sonar-token'          // SonarQube token
        EMAIL_CREDENTIALS = 'mail-cred'      // Gmail username/password
        // Nexus repository info
        NEXUS_URL = 'localhost:8081'
        NEXUS_REPO = 'vprofile-release'
        // Docker image name
        DOCKER_IMAGE = 'myapp-demo:latest'
        // SonarQube server
        SONAR_HOST = 'http://localhost:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/jryyy007/devsecops-demo.git', 
                    credentialsId: "${GIT_CREDENTIALS}"
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Scan') {
            steps {
                sh """
                docker run --rm -e SONAR_HOST_URL=${SONAR_HOST} -e SONAR_LOGIN=${SONAR_TOKEN} \\
                -v ${WORKSPACE}:/usr/src sonarsource/sonar-scanner-cli
                """
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
                    artifacts: [[
                        artifactId: 'myapp',
                        classifier: '',
                        file: 'target/myapp-1.0-SNAPSHOT.jar',
                        type: 'jar'
                    ]]
                )
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Trivy Scan') {
            steps {
                sh """
                trivy image ${DOCKER_IMAGE}
                """
            }
        }
    }

    post {
        success {
            mail to: 'jridim64@gmail.com',
                 from: 'jridim64@gmail.com',
                 subject: "SUCCESS: Build #${env.BUILD_NUMBER}",
                 body: "Build ${env.BUILD_NUMBER} SUCCESSFUL!\nCheck console output at ${env.BUILD_URL}",
                 credentialsId: "${EMAIL_CREDENTIALS}"
        }

        failure {
            mail to: 'jridim64@gmail.com',
                 from: 'jridim64@gmail.com',
                 subject: "FAILURE: Build #${env.BUILD_NUMBER}",
                 body: "Build ${env.BUILD_NUMBER} FAILED!\nCheck console output at ${env.BUILD_URL}",
                 credentialsId: "${EMAIL_CREDENTIALS}"
        }
    }
}
