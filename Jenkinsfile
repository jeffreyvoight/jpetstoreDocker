def label = "ImageBuildPod-${UUID.randomUUID().toString()}"
// podTemplate(yaml: """
// apiVersion: v1
// kind: Pod
// spec:
//   containers:
//   - name: docker
//     image: docker:1.11
//     command: ['cat']
//     tty: true
//     volumeMounts:
//     - name: dockersock
//       mountPath: /var/run/docker.sock
//   volumes:
//   - name: dockersock
//     hostPath:
//       path: /var/run/docker.sock
// """
//   ) {
//
//   def image = "jenkins/jnlp-slave"
//   node(POD_LABEL) {
//     stage('Build Docker image') {
//       git 'https://github.com/jenkinsci/docker-jnlp-slave.git'
//       container('docker') {
//         sh "docker build -t blah/blah 11/alpine/"
//       }
//     }
//   }
// }

podTemplate(
    label: label,
    volumes: [hostPathVolume(name: 'dockersock', hostPath: '/var/run/docker.sock')],
    containers: [
        containerTemplate(name: 'maven',
            image: 'maven:3.6.3-jdk-8',
            ttyEnabled: true,
            command: 'cat'),
        containerTemplate(name: 'docker',
            image: 'docker:latest',
            ttyEnabled: true,
            command: 'cat',
            envVars: [containerEnvVar(key: 'DOCKER_HOST', value: "unix:///var/run/docker.sock")],
            volumeMounts: [name: 'dockersock', mountPath: '/var/run/docker.sock'],
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
//                     sh('mvn verify -DskipITs')
//                     archiveArtifacts artifacts: '**/target/*.war', onlyIfSuccessful: true
//                }
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
