pipeline {
    agent any
    tools {
        jdk 'JDK-17'
    }
    environment {
        SCANNER_HOME = tool 'sonarscanner'
        APP_NAME = "httpd-dash-app"
        RELEASE = "1.0.0"
        appRegistry = "test-build"
    }
    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git branch: 'develop', url: 'https://github.com/ItzAdi29/httpd-dash-app.git'
            }
        }
        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=TestPrj \
                    -Dsonar.projectKey=TestPrj'''
                }
            }
        }
        stage("Quality Gate") {
    	    steps {
        	timeout(time: 10, unit: 'MINUTES') {
            	    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
            	    // true = set pipeline to UNSTABLE, false = don't
            	    waitForQualityGate abortPipeline: true
        	}
    	    }
	    }

	    stage('Build App Image') {
       	    steps {
                script {
                    dockerImage = docker.build( appRegistry + ":$BUILD_NUMBER")
                }
     	    }
    	}
     }    
}