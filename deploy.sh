#!/bin/bash
# 用法: bash deploy.sh <TAG>
TAG=$1
REGISTRY="192.168.88.131:5000"
export TAG
cd /opt/app
# 注意文件名是 deploy-compose.yml，必须显式用 -f 指定，否则 docker compose 默认找 docker-compose.yml
docker compose -f deploy-compose.yml pull app
TAG=$TAG docker compose -f deploy-compose.yml up -d
docker image prune -f
echo "deploy done, tag=$TAG"

