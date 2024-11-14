job('NodeJS example') {
    scm {
        git('https://github.com/pramshy/JenkinsTutorial.git') / 'extensions' / 'hudson.plugins.git.extensions.impl.SparseCheckoutPaths' / 'sparseCheckoutPaths' {
            ['docker-demo'].each {

                node -> // is hudson.plugins.git.GitSCM
                    node / gitConfigName('DSL User')
                    node / gitConfigEmail('jenkins-dsl@newtech.academy')

                mypath ->
                'hudson.plugins.git.extensions.impl.SparseCheckoutPath' {
                    path("${mypath}")
                }
            }
        }
    }
    triggers {
        scm('H/5 * * * *')
    }
    wrappers {
        nodejs('nodejs') // this is the name of the NodeJS installation in 
                         // Manage Jenkins -> Configure Tools -> NodeJS Installations -> Name
    }
    steps {
        shell("cd docker-demo/")
        shell("npm install")
    }
}
