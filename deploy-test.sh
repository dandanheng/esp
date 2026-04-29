#!/bin/bash
# deploy-test.sh - 同步代码到远程并重启 test 容器
# 用法: ./deploy-test.sh [本地代码目录]

REMOTE_HOST="lldd@100.92.85.48"
REMOTE_TEST_DIR="/home/lldd/codes/xiaozhi-server-test"
LOCAL_DIR=${1:-"./xiaozhi-esp32-server/main/xiaozhi-server"}

echo "=== 部署到测试环境 ==="

# 1. 同步代码
echo "[1/3] 同步代码到远程..."
rsync -avz --delete \
    --exclude='__pycache__' \
    --exclude='.git' \
    --exclude='*.pyc' \
    --exclude='venv' \
    --exclude='tmp' \
    --exclude='data' \
    --exclude='models' \
    --exclude='docker-compose.yml' \
    --exclude='docker-compose_all.yml' \
    "$LOCAL_DIR/" "$REMOTE_HOST:$REMOTE_TEST_DIR/"

# 2. 确保 data 目录和模型链接存在
echo "[2/3] 确保环境和模型就绪..."
ssh "$REMOTE_HOST" "
    mkdir -p $REMOTE_TEST_DIR/data
    mkdir -p $REMOTE_TEST_DIR/models/SenseVoiceSmall
    if [ ! -L $REMOTE_TEST_DIR/models/SenseVoiceSmall/model.pt ] && [ ! -f $REMOTE_TEST_DIR/models/SenseVoiceSmall/model.pt ]; then
        ln -sf /home/lldd/codes/xiaozhi-server/models/SenseVoiceSmall/model.pt $REMOTE_TEST_DIR/models/SenseVoiceSmall/model.pt
    fi
"

# 3. 重启 test 容器
echo "[3/3] 重启 test 容器..."
ssh "$REMOTE_HOST" "cd $REMOTE_TEST_DIR && docker compose restart"

echo "=== 部署完成 ==="
echo "测试环境: http://192.168.3.33:8103 (OTA), ws://192.168.3.33:8100 (WebSocket)"
echo "如需切换设备流量到 test: ssh $REMOTE_HOST 'cd $REMOTE_TEST_DIR && bash switch.sh test'"
