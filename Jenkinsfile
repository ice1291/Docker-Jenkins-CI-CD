pipeline {
    agent any
    environment {
        REGISTRY = "192.168.88.131:5000"     // 私有仓库地址 = ci 节点 IP (server1)
        IMAGE    = "demo-flask"              // 镜像名
        TAG      = "${BUILD_NUMBER}"         // 用构建号当不可变标签，保证可回溯
        DEPLOY   = "root@192.168.88.133"     // 部署节点 (server3)
        SSHFLAGS = "-o StrictHostKeyChecking=no"  // 跳过首次连接的 host key 交互
    }
    stages {
        stage('单元测试') {
            steps {
                script {
                    // 在一次性 python 容器里跑测试，环境干净、可复现
                    // 以 root 运行并给可写 HOME，避免 uid1000 无权限装包到 /.local 报 Permission denied
                    docker.image('python:3.12-slim').inside('-u root -e HOME=/root') {
                        sh 'pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple && python -m pytest test_app.py'
                    }
                }
            }
        }
        stage('构建镜像') {
            steps {
                script {
                    docker.build("${REGISTRY}/${IMAGE}:${TAG}")
                }
            }
        }
        stage('推送镜像') {
            steps {
                script {
                    // registry 未开认证，无需凭据；insecure 已在 daemon.json 配好
                    docker.withRegistry("http://${REGISTRY}") {
                        docker.image("${REGISTRY}/${IMAGE}:${TAG}").push()
                    }
                }
            }
        }
        stage('远程部署') {
            steps {
                sshagent(['deploy-ssh']) {
                    sh "ssh $SSHFLAGS $DEPLOY 'mkdir -p /opt/app'"
                    sh "scp $SSHFLAGS deploy-compose.yml deploy.sh nginx.conf $DEPLOY:/opt/app/"
                    sh "ssh $SSHFLAGS $DEPLOY 'cd /opt/app && TAG=${TAG} bash deploy.sh ${TAG}'"
                }
            }
        }
    }
    post {
        failure { echo '❌ 流水线失败，已阻断发布' }
        success { echo '✅ 构建并部署成功' }
    }
}

