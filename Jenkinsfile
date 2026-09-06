def appname = "hello-newapp"
def repo = "NoaKariti"  // Replace with your DockerHub username
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"
def dockerImage
podTemplate(containers: [
      containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent', ttyEnabled: true),
      containerTemplate(name: 'docker', image: 'docker:dind', ttyEnabled: true, privileged: true)
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
                    container('docker') {
                      echo "Security Scanning..."
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
    }
}
