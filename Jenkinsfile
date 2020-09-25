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
            command: 'cat',
            volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')],
            envVars: [containerEnvVar(key: 'DOCKER_HOST', value: "unix:///var/run/docker.sock")],
            privileged: true)
    ])
{
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
//                 stage('Compile') {
//                     sh('mvn compile')
//                 }
//                 stage('Test') {
//                     sh('mvn test')
//                     junit '**/target/surefire-reports/TEST-*.xml'
//                 }
//                 stage('Verify') {
                    sh('mvn verify -DskipITs')
                    archiveArtifacts artifacts: '**/target/*.war', onlyIfSuccessful: true
                }
            }
        }
        stage('Container'){
            container('docker'){
            sh('ls -al /var/run/*')
                sh('docker image build -t ice/jpetstore ./')
            }
        }
    }
}
