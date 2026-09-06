def appname = "hello-newapp"
def repo = "noakariti"
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"
def dockerImage
podTemplate(containers: [
      containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent', ttyEnabled: true),
      containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, privileged: true),
      containerTemplate(name: 'trivy', image: 'aquasec/trivy:latest', command: 'cat', ttyEnabled: true),
      containerTemplate(name: 'kubectl', image: 'alpine/k8s:1.30.2', command: 'cat', ttyEnabled: true),
      containerTemplate(name: 'helm', image: 'alpine/helm:3.14.0', command: 'cat', ttyEnabled: true)
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
        stage('Deploy') {
            container('helm') {
              echo "Rendering Helm template..."
              sh "helm template hello-newapp ./chart --set image.repository=${appimage} --set image.tag=${apptag} > hello-newapp.yaml"
              sh 'cat hello-newapp.yaml'
              archiveArtifacts artifacts: 'hello-newapp.yaml', fingerprint: true
            }
        } //end Deploy
        stage('deploy') {
            container('kubectl') {
              echo "Deploying to Kubernetes..."
              sh '''
                kubectl config set-cluster in-cluster --server=https://kubernetes.default.svc --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
                kubectl config set-credentials in-cluster --token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
                kubectl config set-context in-cluster --cluster=in-cluster --user=in-cluster --namespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
                kubectl config use-context in-cluster
              '''
              sh "sed 's|IMAGE_PLACEHOLDER|${appimage}:${apptag}|' k8s/deployment.yaml | kubectl apply -f - --request-timeout=10s"
            }
        } //end deploy
    }
}
