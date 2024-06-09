pipeline {
    agent any
    tools {
        jdk 'JDK-17'
    }
    environment {
        SCANNER_HOME = tool 'sonarscanner'
        appRegistry = "341324050589.dkr.ecr.eu-west-1.amazonaws.com/test_httpdapprepo"
        ecrRegion = 'ecr:eu-west-1:'
        registryCredential = credentials('awscreds')
        dashRegistry = "https://341324050589.dkr.ecr.eu-west-1.amazonaws.com"
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
        // stage("Quality Gate") {
    	//     steps {
        // 	timeout(time: 10, unit: 'MINUTES') {
        //     	    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
        //     	    // true = set pipeline to UNSTABLE, false = don't
        //     	    waitForQualityGate abortPipeline: true
        // 	}
    	//     }
	    // }

	    stage('Build test Image') {
       	    steps {
                script {
                    dockerImage = docker.build( "httpd_app" + ":$BUILD_NUMBER")
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

        stage('Upload App Image') {
          steps{
            script {
              docker.withRegistry( dashRegistry, ${ecrRegion} + ${registryCredential} ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }
        }
     }    
}