pipeline {
    agent any

    environment {
        // Jenkins Global Variables (Configure in Manage Jenkins -> Configure System)
        NEXUS_URL = 'localhost:8081'
        NEXUS_CREDENTIALS = 'nexus-login'
        NEXUS_REPO = 'maven-releases'
        SONAR_TOKEN = credentials('sonar-token')
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
	DOCKERHUB_USERNAME = "${DOCKERHUB_CREDENTIALS_USR}"
	DOCKERHUB_PASSWORD = "${DOCKERHUB_CREDENTIALS_PSW}"
	PROJECT_NAME = 'myapp'
        PROJECT_VERSION = '1.0-SNAPSHOT'
        ZAP_HOST = 'localhost'
        ZAP_PORT = '8090'
	
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
                SONAR_HOST_URL = 'http://localhost:9000'
            }
            steps {
                script {
                    sh "mvn sonar:sonar -Dsonar.projectKey=${PROJECT_NAME} -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_TOKEN}"
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                script {
                    def repo = 'maven-releases'
                    if (env.PROJECT_VERSION?.endsWith('-SNAPSHOT')) {
                        repo = 'maven-snapshots'
                    }
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: "${NEXUS_URL}",
                        groupId: 'com.example',
                        version: "${env.PROJECT_VERSION}",
                        repository: repo,
                        credentialsId: "${NEXUS_CREDENTIALS}",
                        artifacts: [
                            [artifactId: 'myapp',
                             type: 'jar',
                             classifier: '',
                             file: "target/myapp-${env.PROJECT_VERSION}.jar"]
                        ]
                    )
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t myapp:latest ."
                }
            }
        }

        stage('ZAP Scan') {
    steps {
        script {
            echo 'Starting ZAP scan using running container...'

            // Wait for ZAP daemon to be ready
            sh 'sleep 10'

            // Trigger the quick scan through ZAP's REST API
            sh '''
                curl "http://localhost:8090/JSON/ascan/action/scan/?url=http://localhost:8080"
                
                # Wait for scan completion
                echo "Waiting for ZAP scan to finish..."
                sleep 60

                # Generate the HTML report through the API
                curl "http://localhost:8090/OTHER/core/other/htmlreport/" -o zap-report.html
            '''

            // Archive the report for Jenkins
            archiveArtifacts artifacts: 'zap-report.html', fingerprint: true
        }
    }
}

stage('Publish Docker Image') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'dockerhub-cred',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
            sh "docker tag ${PROJECT_NAME}:latest $DOCKER_USER/${PROJECT_NAME}:latest"
            sh "docker push $DOCKER_USER/${PROJECT_NAME}:latest"
        }
    }
}



stage('Deploy to Docker') {
    steps {
        script {
            sh """
                docker stop ${PROJECT_NAME} || true
                docker rm ${PROJECT_NAME} || true
                docker run -d --name ${PROJECT_NAME} -p 8081:8080 $DOCKERHUB_USERNAME/${PROJECT_NAME}:latest
            """
        }
    }
}



        stage('Trivy Scan') {
            steps {
                script {
                    // Scan the Docker image for vulnerabilities
                    sh "trivy image --exit-code 1 --severity HIGH,CRITICAL myapp:latest || true"
                }
            }
        }
    }

    post {
        success {
            emailext(
                to: 'jridim64@gmail.com',
                subject: "${PROJECT_NAME} - Build #${BUILD_NUMBER} - SUCCESS",
                body: """Build SUCCESSFUL for ${PROJECT_NAME}.
Check console output at ${BUILD_URL}.
ZAP report archived: ${BUILD_URL}artifact/zap-report.html"""
            )
        }
        failure {
            emailext(
                to: 'jridim64@gmail.com',
                subject: "${PROJECT_NAME} - Build #${BUILD_NUMBER} - FAILURE",
                body: """Build FAILED for ${PROJECT_NAME}.
Check console output at ${BUILD_URL}."""
            )
        }
    }
}
