pipeline {
    agent any
    tools {
        maven 'Maven 3.3.9'
        jdk 'jdk8'
    }
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                '''
            }
        }

        stage ('Build') {
            steps {
                sh 'mvn clean install'
            }
            post {
                success {
                    junit 'target/surefire-reports/**/*.xml'
                }
            }
        }


        stage ('approve') {
            steps {
                timeout(time: 7, unit: 'DAYS') {
                    input message: 'Do you want to deploy?', submitter: 'product-management'
                }
            }
        }

        stage ('Deploy') {
            steps {
                sh 'echo This will be deployed'
            }
        }
    }
}

