pipeline {
    agent any
    tools {
        jdk 'JDK-17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonarscanner'
        appRegistry = '341324050589.dkr.ecr.eu-west-1.amazonaws.com/test_httpdapprepo'
        registryCredential = 'ecr:eu-west-1:awscreds'
        awsCredential = 'awscreds'
        dashRegistry = 'https://341324050589.dkr.ecr.eu-west-1.amazonaws.com'
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

	   // stage('Build test Image') {
    //   	    steps {
    //             script {
    //                 dockerImage = docker.build( "httpd_app" + ":$BUILD_NUMBER")
    //             }
    //  	    }
    // 	}

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
              docker.withRegistry( dashRegistry, registryCredential ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }
        }
        
    //     stage('Deploy') {
    //         steps{
    //             withAWS(credentials: awsCredential, region: "eu-west-1") {
    //                 script {
	// 		            sh """
    //                         aws ecs register-task-definition --cli-input-json file://task-definition.json --region="eu-west-1"
    //                         REVISION=`aws ecs describe-task-definition --task-definition "test_ecstd" --region "eu-west-1" | jq .taskDefinition.revision`
    //                         echo "Task Definition ARN: \${REVISION}"
    //                         aws ecs update-service --cluster "test_ecsclu" --service "Test_EcsSer-a03dbee" --task-definition "test_ecstd":"\${REVISION}" --desired-count "1"
    //                         aws ecs wait services-stable --cluster "test_ecsclu" --services "Test_EcsSer-a03dbee"
    //                     """
    //                 }
    //             } 
    //         }
    //         // TASK_DEFINITION_ARN=\$(aws ecs register-task-definition --cli-input-json file://task-definition.json | jq -r '.taskDefinition.taskDefinitionArn')
    //         //                 echo "Task Definition ARN: \${TASK_DEFINITION_ARN}"
    //    }
    }    
}