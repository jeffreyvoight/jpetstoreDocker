def label = "ImageBuildPod-${UUID.randomUUID().toString()}"

podTemplate(
    label: label,
    containers: [
        containerTemplate(name: 'maven',
            image: 'maven:3.6.3-jdk-8',
            ttyEnabled: true,
            command: 'cat'),
        containerTemplate(name: 'docker',
            image: 'docker:latest',
            ttyEnabled: true,
            command: 'cat')
        ]
) {
    node(label) {
        stage('Build') {
            container('maven') {
                stage('Clone') {
                    checkout(
                        [
                            $class                           : 'GitSCM',
                            branches                         : scm.branches,
                            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                            extensions                       : scm.extensions,
                            submoduleCfg                     : [],
                            userRemoteConfigs                : scm.userRemoteConfigs
                        ]
                    )
                }
                stage('Compile') {
                    sh('mvn compile')
                }
                stage('Test') {
                    sh('mvn test')
                    junit '**/target/surefire-reports/TEST-*.xml'
                }
                stage('Verify') {
                    sh('mvn verify -DskipITs')
                    archiveArtifacts artifacts: '**/target/*.war', onlyIfSuccessful: true
                }
            }
        stage('Container'){
            container('docker'){
                sh('docker image build -t ice/jpetstore ./')
            }
        }
    }
}