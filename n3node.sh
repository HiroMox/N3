#!/bin/bash

# 检查是否已安装 Docker Compose
if ! docker compose version &>/dev/null; then
  echo "Docker Compose 未安装。开始安装..."
  sudo apt update
  wget https://get.docker.com/ -O docker.sh
  sudo sh docker.sh
  rm docker.sh
  echo "Docker Compose 安装完成。"
else
  echo "Docker Compose 已安装。"
fi

# 创建 Network3 文件夹并进入
mkdir -p Network3
cd Network3 || exit

# 提示用户输入 Network3 注册的邮箱地址
read -p "请输入 Network3 注册的邮箱地址后按回车执行下一步：" email_address

# 创建 docker-compose.yml 文件并写入内容
cat <<EOL >docker-compose.yml
version: '3.3'

services:
  network3-01:
    image: aron666/network3-ai
    container_name: network3-01
    environment:
      - EMAIL=$email_address
    ports:
      - 8080:8080/tcp
    volumes:
      - ./wireguard:/usr/local/etc/wireguard
    healthcheck:
      test: curl -fs http://localhost:8080/ || exit 1
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 30s
    privileged: true
    devices:
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    restart: always

  autoheal:
    restart: always
    image: willfarrell/autoheal
    container_name: autoheal
    environment:
      - AUTOHEAL_CONTAINER_LABEL=all
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
EOL

echo "docker-compose.yml 文件已生成。"

# 运行 Docker Compose 程序
echo "启动服务中..."
docker compose up -d

echo "服务已启动。"
echo "==================== 操作提示 ===================="
echo "1. 查看日志："
echo "   cd Network3 && docker compose logs"
echo
echo "2. 重启程序："
echo "   cd Network3 && docker compose down && docker compose up -d"
echo
echo "3. 更新程序："
echo "   cd Network3 && docker compose down && docker compose pull && docker compose up -d"
echo "=================================================="
