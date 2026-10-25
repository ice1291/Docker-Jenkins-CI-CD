pipeline {
    agent any
    environment {
        REGISTRY = "192.168.88.131:5000"
        IMAGE    = "demo-flask"
        TAG      = "${BUILD_NUMBER}"
    }
    stages {
        stage('单元测试') {
            steps { script {
                docker.image('python:3.12-slim').inside('-u root -e HOME=/root') {
                    sh 'pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple && python -m pytest test_app.py'
                }
            }}
        }
        stage('构建镜像') {
            steps { script {
                docker.build("${REGISTRY}/${IMAGE}:${TAG}")
            }}
        }
        stage('推送镜像') {
            steps { script {
                docker.withRegistry("http://${REGISTRY}") {
                    docker.image("${REGISTRY}/${IMAGE}:${TAG}").push()
                }
            }}
        }
        stage('远程部署') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'deploy-ssh', keyFileVariable: 'KEY_FILE', usernameVariable: 'KEY_USER')]) {
                    script {
                        def remote = [:]
                        remote.name = 'server3'
                        remote.host = '192.168.88.133'
                        remote.user = KEY_USER
                        remote.identityFile = KEY_FILE
                        remote.allowAnyHosts = true
                        sshCommand remote: remote, command: 'mkdir -p /opt/app'
                        sshPut remote: remote, from: 'deploy-compose.yml', into: '/opt/app/'
                        sshPut remote: remote, from: 'deploy.sh', into: '/opt/app/'
                        sshPut remote: remote, from: 'nginx.conf', into: '/opt/app/'
                        sshCommand remote: remote, command: "cd /opt/app && TAG=${TAG} bash deploy.sh ${TAG}"
                    }
                }
            }
        }
    }
    post {
        failure { echo '❌ 流水线失败，已阻断发布' }
        success { echo '✅ 构建并部署成功' }
    }
}
