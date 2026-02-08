# frpc-custom-image

## 项目简介
本项目用于构建基于`alpine:latest`的frpc镜像，自动下载并集成frpc二进制文件，支持构建时使用代理。

## 使用方法

### 1. 构建镜像

```sh
./build.sh [--proxy <代理地址>]
```

参数说明：
- `--proxy <代理地址>`：可选，指定构建时使用的代理（如拉取基础镜像或frpc二进制文件时网络受限）。代理地址需为完整URL，如 `http://127.0.0.1:7890`。脚本会自动将代理环境变量传递给docker/podman构建进程。

示例：
```sh
./build.sh --proxy http://127.0.0.1:7890
```

### 2. 镜像内容
- 基础镜像：`alpine:latest`
- 包含frpc二进制文件（版本：0.67.0）
- 镜像入口命令为`frpc`

### 3. 配置和部署

#### 配置文件

复制配置模板并修改：
```sh
cp frpc.toml.demo frpc.toml
# 编辑 frpc.toml，填入服务器地址、端口、token等信息
```

配置文件使用TOML格式，示例见 `frpc.toml.demo`。

#### 部署容器

使用部署脚本启动容器：
```sh
./deploy.sh [配置文件路径]
```

默认使用 `frpc.toml`，后台运行，bridge网络模式。

**网络模式说明：**
- **bridge模式**（默认）：容器独立网络，访问宿主机需使用网关IP（如10.88.0.1）。SSH日志显示容器IP或网关IP。
- **host模式**：容器共享宿主机网络，使用127.0.0.1即可访问宿主机服务。SSH日志显示真实远程客户端IP，适合安全审计。

若需使用host模式，修改 `deploy.sh` 中 `--net=bridge` 为 `--net=host`，并将配置文件中的 `localIP` 改为 `127.0.0.1`。

#### 容器管理

```sh
# 查看日志
podman logs -f frpc

# 停止容器
podman stop frpc

# 删除容器
podman rm frpc

# 重启容器
./deploy.sh
```

### 4. 可定制项
- 支持通过修改脚本更换frpc版本
- 可扩展支持多架构

## 文件说明
- `build.sh`：镜像构建脚本，支持代理参数
- `Dockerfile`：镜像构建文件
- `deploy.sh`：容器部署脚本，支持后台运行
- `frpc.toml.demo`：配置文件模板
- `.gitignore`：Git忽略规则（frpc二进制、frpc.toml配置）

## 故障排查

### 容器无法访问宿主机服务

1. 检查网络连通性：
```sh
podman exec -it frpc sh
nc -zv <宿主机IP> <端口>
```

2. 若使用bridge模式，检查宿主机网关IP：
```sh
ifconfig | grep cni-podman
```
使用可达的网关IP（如10.88.0.1或10.89.0.1）作为 `localIP`。

3. 推荐使用host模式避免网络问题。

### 查看frpc日志

```sh
podman logs --tail 50 frpc
```

## 注意事项
- 若使用podman替代docker，脚本同样适用
- 配置文件 `frpc.toml` 包含敏感信息，不应提交到版本控制
- 若代理无效，请检查本机代理服务及环境变量设置

## 参考链接
- frp项目主页：https://github.com/fatedier/frp
- frp TOML配置文档：https://github.com/fatedier/frp/blob/master/doc/frpc.toml

---
如需进一步定制或有疑问，请联系维护者。
