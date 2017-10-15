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


        stage('Decide to deploy') {
            agent none
            steps {
                checkpoint 'Build is successful and ready to deploy'
                script {
                    env.DEPLOY_TO_MOB_TEST = input message: 'Approval required',
                            submitter: 'authenticated',
                            parameters: [choice(name: 'Deploy to production', choices: 'no\nyes', description: 'Choose "yes" if you want to deploy to production')]
                }
            }
        }

        stage ('Deployment to production') {
            agent {label 'prod-deploy'}
            when {
                environment name:'approval_answer', value:"true"
            }
            steps {
                sh 'echo This will be deployed'
            }
        }
    }
}

