#!/bin/bash
# 用法: bash deploy.sh <TAG>
TAG=$1
REGISTRY="192.168.88.131:5000"
export TAG
cd /opt/app
docker compose pull app
TAG=$TAG docker compose up -d
docker image prune -f
echo "deploy done, tag=$TAG"
