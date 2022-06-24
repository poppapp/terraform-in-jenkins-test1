pipeline {
  agent any
  options {
    skipDefaultCheckout(true)
  }
  stages{
    stage('clean workspace') {
      steps {
        cleanWs()
      }
    }
    stage('checkout') {
      steps {
        checkout scm
      }
    }
	stage('declare aws vars') {
      steps {
		sh 'export AWS_ACCESS_KEY_ID=AKIATGW5OSJZT3NH57YE'
		sh 'export AWS_SECRET_ACCESS_KEY=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'
		sh 'export AWS_DEFAULT_REGION=us-east-1'
      }
    }
    stage('terraform') {
      steps {
        sh './terraformw apply -auto-approve -no-color'
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}
