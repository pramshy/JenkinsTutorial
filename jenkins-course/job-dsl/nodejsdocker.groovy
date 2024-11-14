job('NodeJS Docker example') {
    scm {
        git() {
            remote {
                url("https://github.com/pramshy/JenkinsTutorial.git")
            }

            branch('*/master')

            extensions {
                sparseCheckoutPaths {
                    sparseCheckoutPaths {
                        sparseCheckoutPath {
                            path('docker-demo')
                        }
                    }
                }
            }
        }
    }
    steps {
        dockerBuildAndPublish {
            repositoryName('prsharma/jenkins-node-demo')
            tag('${GIT_REVISION,length=9}')
            registryCredentials('dockerhub')
            forcePull(false)
            forceTag(false)
            createFingerprints(false)
            skipDecorate()
            buildContext('docker-demo')
        }
    }
}
