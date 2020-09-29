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
        stage('Container') {
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
                configFileProvider([configFile(fileId: 'mavennexus', variable: 'MAVEN_CONFIG')]) {
                    stage('Compile') {
                        sh('mvn -s ${MAVEN_CONFIG} compile')
                    }
                    stage ('SonarQube analysis') {
                        withSonarQubeEnv('sonarqube') {
                            sh 'mvn -s ${MAVEN_CONFIG} sonar:sonar'
                        }
                    }
                    stage ('SonarQube quality gate') {
                        timeout(time: 10, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: true
                        }
                    }
                    stage('Test') {
                        sh('mvn -s ${MAVEN_CONFIG} test')
                        junit '**/target/surefire-reports/TEST-*.xml'
                    }
                    stage('Verify') {
                        sh('mvn -s ${MAVEN_CONFIG} verify -DskipITs')
                    archiveArtifacts artifacts: '**/target/*.war', onlyIfSuccessful: true
               }}
            }
        }
        stage('Container'){
            container('docker'){
                docker.withRegistry('https://container.dhsice.name', 'nexuslogin') {
                    def customImage = docker.build("ice/jpetstore:${env.BUILD_ID}")
                    /* Push the container to the custom Registry */
                    customImage.push()

//                     echo('Logging in to container.dhsice.name')
//                     sh('docker login -u ${USERNAME} -p ${USERPASS} container.dhsice.name')
//                     echo('Building docker image');
//                     sh('docker build -t container.dhsice.name/ice/jpetstore:latest')
//                     echo('Pushing docker image')
//                     sh('docker push container.dhsice.name/ice/jpetstore:latest')
                }
            }
        }
    }
}
