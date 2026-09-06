def appname = "hello-newapp"
def repo = "NoaKariti"  // Replace with your DockerHub username
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"
podTemplate(containers: [
      containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent', ttyEnabled: true),
      containerTemplate(name: 'docker', image: 'docker:dind', command: 'cat', ttyEnabled: true, privileged: true),
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
            container('docker') {
              echo "Building docker image..."
              sh "echo docker push $appimage"
            }
        } //end build
        stage('helm install') {
            container('helm') {
              echo "Installing Helm chart..."
              sh "echo helm install ./chart"
            }
        } //end helm install
        stage('helm template') {
            container('helm') {
              echo "Templating Helm chart..."
              sh "echo helm template newapp ./chart"
            }
        } //end helm template
    }
}

