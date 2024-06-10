pipeline {
    agent any
    tools {
        jdk 'JDK-17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonarscanner'
        REGION = 'eu-west-1'
        TASK_DEF = 'test_ecstd'
        ECS_CLUSTER = 'test_ecsclu'
        ECS_SERVICE = 'test_ecsser'
        ECS_COUNT = '1'
        appRegistry = '341324050589.dkr.ecr.eu-west-1.amazonaws.com/test_httpdapprepo'
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
              docker.withRegistry( dashRegistry, "ecr:${REGION}:" + awsCredential ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }
        }
        
        stage('Deploy') {
            steps{
                withAWS(credentials: awsCredential, region: "${REGION}") {
                    script {
			            sh """
                            aws ecs register-task-definition --cli-input-json file://task-definition.json --region=\${REGION}
                            REVISION=`aws ecs describe-task-definition --task-definition \${TASK_DEF} --region \${REGION} | jq .taskDefinition.revision`
                            echo "Task Definition ARN: \${REVISION}"
                            aws ecs update-service --cluster \${ECS_CLUSTER} --service \${ECS_SERVICE} --task-definition \${TASK_DEF}:"\${REVISION}" --desired-count \${ECS_COUNT}
                            aws ecs wait services-stable --cluster \${ECS_CLUSTER} --services \${ECS_SERVICE}
                        """
                    }
                } 
            }
       }
            // TASK_DEFINITION_ARN=\$(aws ecs register-task-definition --cli-input-json file://task-definition.json | jq -r '.taskDefinition.taskDefinitionArn')
            // echo "Task Definition ARN: \${TASK_DEFINITION_ARN}"
    }    
}