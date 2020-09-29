def label = "jpetstorePod-${UUID.randomUUID().toString()}"

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
                    envVars: [containerEnvVar(key: 'DOCKER_HOST', value: "unix:///var/run/docker.sock")],
                    privileged: true)
        ],
        volumes: [ hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock') ])
{
    node(label) {
        stage('Clone') {
            container('maven'){
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
            container('docker'){
                docker.withRegistry('https://container.dhsice.name', 'nexuslogin') {
                    sh('wget https://nexus.dhsice.name/repository/maven-snapshots/org/mybatis/jpetstore/6.0.3-SNAPSHOT/jpetstore-6.0.3-20200929.153558-1.war')
                    def customImage = docker.build("ice/jpetstore:${env.BUILD_ID}")
                    /* Push the container to the custom Registry */
                    customImage.push()
                }
            }
        }
    }
}
