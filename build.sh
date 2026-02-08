#!/bin/sh
# 构建frpc镜像脚本
# 可选代理，自动下载frpc二进制包

# 可选参数：--proxy <代理地址>
FRP_VERSION="0.67.0"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
PROXY=""

# 解析参数
while [ $# -gt 0 ]; do
	case "$1" in
		--proxy)
			PROXY="$2"
			shift 2
			;;
		*)
			shift
			;;
	esac
done

if [ -n "$PROXY" ]; then
	export HTTP_PROXY="$PROXY"
	export HTTPS_PROXY="$PROXY"
	echo "使用代理: $PROXY"
	BUILD_ENV="--build-arg HTTP_PROXY=$PROXY --build-arg HTTPS_PROXY=$PROXY"
else
	BUILD_ENV=""
fi

# 下载frpc二进制包
echo "下载frpc二进制包..."
curl -L "$FRP_URL" -o frp.tar.gz
tar -xzf frp.tar.gz
cp frp_${FRP_VERSION}_linux_amd64/frpc ./frpc
rm -rf frp.tar.gz frp_${FRP_VERSION}_linux_amd64

# 构建镜像
echo "开始构建镜像..."
docker build $BUILD_ENV --build-arg FRP_VERSION="$FRP_VERSION" -t frpc:latest .
echo "镜像构建完成: frpc:latest"
