def appname = "hello-newapp"
def repo = "noakariti"
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"
def dockerImage
podTemplate(containers: [
      containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent', ttyEnabled: true),
      containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, privileged: true),
      containerTemplate(name: 'trivy', image: 'aquasec/trivy:latest', command: 'cat', ttyEnabled: true),
      containerTemplate(name: 'kubectl', image: 'bitnami/kubectl:latest', command: 'cat', ttyEnabled: true)
  ])
  {
    node(POD_LABEL) {
        stage('chackout') {
            container('jnlp') {
            sh '/usr/bin/git config --global http.sslVerify false'
	    checkout scm
          }
        } // end chackout
        stage('build') {
            parallel(
                'build': {
                    container('docker') {
                      echo "Building docker image..."
                      sh 'until docker info >/dev/null 2>&1; do echo "Waiting for docker daemon..."; sleep 1; done'
                      script {
                        dockerImage = docker.build("${appimage}:${apptag}")
                      }
                    }
                },
                'Security Scan': {
                    container('trivy') {
                      echo "Security Scanning with Trivy..."
                      sh 'trivy fs --exit-code 0 --severity HIGH,CRITICAL .'
                    }
                }
            )
        } //end build
        stage('push') {
            container('docker') {
              script {
                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                  dockerImage.push()
                }
              }
            }
        } //end push
        stage('deploy') {
            container('kubectl') {
              echo "Deploying to Kubernetes..."
              timeout(time: 30, unit: 'SECONDS') {
                sh 'kubectl cluster-info'
                sh 'kubectl auth can-i create deployments -n default'
              }
              sh "sed 's|IMAGE_PLACEHOLDER|${appimage}:${apptag}|' k8s/deployment.yaml | kubectl apply -f -"
            }
        } //end deploy
    }
}
