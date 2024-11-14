job('NodeJS example') {
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

    triggers {
        scm('H/5 * * * *')
    }
    wrappers {
        nodejs('nodejs_4.6.1') // this is the name of the NodeJS installation in
        // Manage Jenkins -> Configure Tools -> NodeJS Installations -> Name
    }
    steps {
        shell('cd docker-demo/ && npm install')
    }
}
