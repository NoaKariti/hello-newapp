// properties([
//     parameters([
//         string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
//     ])
// ])

def branch = env.BRANCH_NAME
def build = env.BUILD_NUMBER
def appname = "k8s-deployer"
def artifactory = "docker.io" 
def repo = "elevy99927" 
def appimage = "${repo}/${appname}"
def apptag = params.IMAGE_TAG

podTemplate(containers: [
      containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent', ttyEnabled: true),
      containerTemplate(name: 'deployer', image: 'elevy99927/k8s-deployer:latest', command: 'cat', ttyEnabled: true),
      containerTemplate(name: 'docker', image: 'gcr.io/kaniko-project/executor:v1.23.0-debug', command: '/busybox/cat', ttyEnabled: true)
  ],
  volumes: [
     secretVolume(mountPath: '/kaniko/.docker/', secretName: 'docker-cred'),
     secretVolume(mountPath: '/var/run/secrets/github-token', secretName: 'github-token')

  ])  {
    node(POD_LABEL) {
        stage('checkout') {
            container('jnlp') {
                sh '/usr/bin/git config --global http.sslVerify false'
                checkout scm
            }
        }

        stage('calc-version') {
            container('deployer') {
                script {
                    def currentVersion = sh(
                        script: """#!/bin/bash
                            TOKEN=\$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${appimage}:pull" | jq -r .token)
                            DIGEST=\$(curl -s -H "Authorization: Bearer \$TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "https://registry-1.docker.io/v2/${appimage}/manifests/latest" | jq -r '.config.digest // empty')
                            if [ -z "\$DIGEST" ]; then
                                echo "1"
                            else
                                CURRENT=\$(curl -s -H "Authorization: Bearer \$TOKEN" -H "Accept: application/vnd.docker.container.image.v1+json" "https://registry-1.docker.io/v2/${appimage}/blobs/\$DIGEST" | jq -r '.config.Labels.VERSION // empty')
                                if [ -z "\$CURRENT" ]; then
                                    echo "1"
                                else
                                    echo \$((\$CURRENT + 1))
                                fi
                            fi
                        """,
                        returnStdout: true
                    ).trim()
                    env.VERSION = currentVersion
                }
                echo "Next VERSION: ${env.VERSION}"
            }
        }

        stage('build') {
            container('docker') {
                echo "Building with VERSION=${env.VERSION}"
                sh "/kaniko/executor --force --context=dir://${env.WORKSPACE} --build-arg VERSION=${env.VERSION} --destination=${appimage}:${apptag} --destination=${appimage}:latest"
            }
        }

    }
  }

