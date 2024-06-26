pipeline {
    agent any
	tools{
	    maven 'M2_HOME'
        }

        environment {	
	    DOCKERHUB_CREDENTIALS=credentials('dockerloginid')
	} 
    
    stages {
        stage('SCM Checkout') {
            steps {
                git 'https://github.com/iamanjalibhat/Finance-me.git'
            }
		}
        stage('Maven Build') {
            steps {
                // Run Maven on a Unix agent.
                sh "mvn -Dmaven.test.failure.ignore=true clean package"
            }
		}
        stage("Docker build"){
            steps {
		sh 'docker version'
		sh "docker build -t anjalibhat/finance-me-app:${BUILD_NUMBER} ."
		sh 'docker image list'
		sh "docker tag anjalibhat/finance-me-app:${BUILD_NUMBER} anjalibhat/finance-me-app:latest"
            }
        } 
	stage('Login to DockerHub') {
	     steps {
		sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
	     }
	}
	stage('Push to DockerHub') {
             steps {
		sh "docker push anjalibhat/finance-me-app:latest"
	     }
	}
	stage('Create Infrastructure using terraform') {
	     steps {
		dir('scripts') {
			withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'JenkinsIAMuser', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
			sh 'terraform init'
			sh 'terraform validate'
			sh 'terraform apply --auto-approve -lock=false'
			}
                }
	     }
       }
    }
}
