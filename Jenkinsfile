pipeline {
    agent any

    environment {
        // Nexus config
        NEXUS_URL = 'http://localhost:8081'              // your Nexus URL
        NEXUS_REPO = 'vprofile-release'                 // repository in Nexus
        NEXUS_CREDENTIALS = 'nexus-login'               // Jenkins global credentials ID for Nexus

        // SonarQube
        SONARQUBE = 'sonar-server'                      // Jenkins SonarQube server ID
        SONAR_TOKEN = 'sonar-token'                     // Jenkins global secret text ID for SonarQube

        // Email
        EMAIL_TO = 'jridim64@gmail.com'
        EMAIL_FROM = 'jridim64@gmail.com'

        // Docker
        DOCKER_IMAGE = 'myapp:latest'
    }

    tools {
        // Maven installation name configured in Jenkins
        maven 'MAVEN3'
        jdk 'JDK21'
    }

    stages {

        stage('Checkout') {
            steps {
                git credentialsId: 'github-cred',
                    url: 'https://github.com/jryyy007/devsecops-demo.git',
                    branch: 'main'
            }
        }

        stage('Build with Maven') {
            steps {
                withMaven(maven: 'MAVEN3') {
                    sh 'mvn clean package'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    sh "mvn sonar:sonar -Dsonar.login=${SONAR_TOKEN}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUS_URL}",
                    credentialsId: "${NEXUS_CREDENTIALS}",
                    repository: "${NEXUS_REPO}",
                    artifacts: [[
                        groupId: 'com.example',                  // must match pom.xml
                        artifactId: 'myapp',
                        version: '1.0-SNAPSHOT',
                        classifier: '',
                        file: 'target/myapp-1.0-SNAPSHOT.jar',
                        type: 'jar'
                    ]]
                )
            }
        }
    }

    post {
        success {
            mail to: "${EMAIL_TO}",
                 from: "${EMAIL_FROM}",
                 subject: "SUCCESS: Build #${env.BUILD_NUMBER}",
                 body: "Build #${env.BUILD_NUMBER} SUCCESSFUL!\nCheck console output at ${env.BUILD_URL}"
        }

        failure {
            mail to: "${EMAIL_TO}",
                 from: "${EMAIL_FROM}",
                 subject: "FAILURE: Build #${env.BUILD_NUMBER}",
                 body: "Build #${env.BUILD_NUMBER} FAILED!\nCheck console output at ${env.BUILD_URL}"
        }
    }
}
