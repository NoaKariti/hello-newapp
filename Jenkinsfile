def appname = "hello-newapp"
def repo = "NoaKariti"  // Replace with your DockerHub username
def appimage = "docker.io/${repo}/${appname}"
def apptag = "${env.BUILD_NUMBER}"

podTemplate(cloud: 'kubernetes', containers: [
    containerTemplate(
        name: 'jnlp', 
        image: 'jenkins/inbound-agent:latest'
    ),
     containerTemplate(
        name: 'docker', 
        image: 'docker:26-dind', // Use the latest stable DinD image
        privileged: true,      // Essential for Docker daemon to run
        args: '--storage-driver=vfs' // VFS is safest for K8s, though slower
    ),
    containerTemplate(
        name: 'helm',
        image: 'alpine/helm:3.14.0',
        command: 'cat',
        ttyEnabled: true
    )],
  volumes: [
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false) // Q: Why do we need this volume?
  ]) {
    node(POD_LABEL) {
        stage('chackout') {
            container('jnlp') {
            sh '/usr/bin/git config --global http.sslVerify false'
	    checkout scm
          }
        } // end chackout

        stage('Hello') {
            container('docker') {
              echo "Building docker image..."
              sh "echo docker push $appimage"
            }
        } //end hello

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
