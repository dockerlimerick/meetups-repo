pipeline {
    agent any
    
    stages {
        // Pull code from Github
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        // Get dependencies and run tests
        stage('Build & Test') {
            steps {
                sh './docker/build_and_test.sh '
            }
            
            post {
                // Save our results
                always {
                    junit 'docker_demo_2/artifacts/tests_output.xml'
                }
            }
        }
    }
}