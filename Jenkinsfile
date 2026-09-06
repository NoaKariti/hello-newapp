def appname = "hello-newapp"
def repo = "NoaKariti"  // Replace with your DockerHub username
def appimage = "${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"
def dockerImage
podTemplate(containers: [
      containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent', ttyEnabled: true),
      containerTemplate(name: 'docker', image: 'docker:dind', command: 'cat', ttyEnabled: true, privileged: true)
  ])
  {
    node(POD_LABEL) {
        stage('checkout') {
            container('jnlp') {
            sh '/usr/bin/git config --global http.sslVerify false'
	    checkout scm
          }
        } // end checkout
        stage('build') {
            parallel(
                'build': {
                    container('docker') {
                      echo "Building docker image..."
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
        // Requires the "Docker Pipeline" plugin (docker-workflow) for docker.build/docker.withRegistry.
        // Install: Manage Jenkins > Plugins > Available plugins > "Docker Pipeline".
        // Configure credentials: Manage Jenkins > Credentials > (global) > Add Credentials
        //   Kind: "Username with password", ID: dockerhub-creds, Username: Docker Hub username,
        //   Password: a Docker Hub Access Token (Account Settings > Security > Access Tokens), not your account password.
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
