#!/bin/sh
# frpc容器部署脚本
# 用法: ./deploy.sh <配置文件路径> [其他frpc参数]

CONFIG_FILE=${1:-frpc.toml}
shift

if [ ! -f "$CONFIG_FILE" ]; then
  echo "配置文件不存在: $CONFIG_FILE"
  exit 1
fi

# 停止并删除旧容器（如果存在）
podman rm -f frpc 2>/dev/null

# 启动frpc容器（后台运行，网桥模式，开机自启动）
podman run -d \
  --name frpc \
  --restart=always \
  --net=bridge \
  -v "$PWD/$CONFIG_FILE:/etc/frpc.toml:ro,Z" \
  frpc:latest -c /etc/frpc.toml "$@"

echo "frpc容器已启动（后台运行）"
echo "查看日志: podman logs -f frpc"
echo "停止容器: podman stop frpc"
echo "删除容器: podman rm frpc"
