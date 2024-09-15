#!/bin/bash

# 用户目录
USER_HOME="/usr/home/$(whoami)"
VENV_PATH="$USER_HOME/venv_webdav"

# 可选的编译标志
export CFLAGS="-I/usr/local/include"
export CXXFLAGS="-I/usr/local/include"

cd "$USER_HOME"

# 安装 PM2 (使用 npm)
if [ ! -f "$USER_HOME/node_modules/pm2/bin/pm2" ]; then
    echo "正在安装 PM2..."
    npm install pm2
else
    echo "PM2 已安装。"
fi

# 创建并激活虚拟环境
if [ ! -d "$VENV_PATH" ]; then
    echo "创建虚拟环境..."
    virtualenv "$VENV_PATH"
fi

# 激活虚拟环境
echo "激活虚拟环境: $VENV_PATH"
source "$VENV_PATH/bin/activate"

# 检查虚拟环境是否激活
if [ "$VIRTUAL_ENV" != "" ]; then
    echo "虚拟环境已激活: $VIRTUAL_ENV"
else
    echo "虚拟环境激活失败，请检查配置。"
    exit 1
fi

# 确认 PM2 安装路径 (npm 安装路径)
PM2_PATH="$USER_HOME/node_modules/pm2/bin/pm2"
echo "PM2 安装路径: $PM2_PATH"

# 安装 WsgiDAV 和 Cheroot
echo "安装 WsgiDAV 和 Cheroot..."
pip install wsgidav cheroot python-dotenv

# 创建 WsgiDAV 配置文件
WSGIDAV_CONFIG="$USER_HOME/wsgidav.yaml"
cat <<EOF > "$WSGIDAV_CONFIG"
# WsgiDAV configuration file
host: 0.0.0.0
port: 8080  # 请根据实际情况修改端口号
root: $USER_HOME/webdav
provider_mapping:
  "/":
    provider: wsgidav.fs_dav_provider.FilesystemProvider
    args: ["$USER_HOME/webdav"]
http_authenticator:
  domain_controller: wsgidav.dc.simple_dc.SimpleDomainController
  accept_basic: true
  accept_digest: true
  default_to_digest: true
simple_dc:
  user_mapping:
    "*":
      "user": "password"  # 请修改为用户名和密码
EOF

# 创建 WebDAV 根目录
mkdir -p "$USER_HOME/webdav"

# 使用 PM2 启动 WsgiDAV
echo "使用 PM2 启动 WsgiDAV..."
$PM2_PATH start wsgidav -- --config="$WSGIDAV_CONFIG"

# 检查 WsgiDAV 是否启动成功
if $PM2_PATH list | grep -q "wsgidav"; then
    echo "WsgiDAV 已成功启动。"
else
    echo "WsgiDAV 启动失败，请检查配置。"
    exit 1
fi

# 保存 PM2 状态
$PM2_PATH save

# 设置 cron 任务在重启后自动启动 PM2
(crontab -l 2>/dev/null; echo "@reboot $PM2_PATH resurrect") | crontab -

# 提示安装完成
echo "WsgiDAV 安装完成，您可以通过 ./setup_wsgidav.sh 进行进一步配置。"

# 询问用户是否继续执行配置脚本
read -p "是否现在运行 ./setup_wsgidav.sh 进行配置？(输入 'yes' 继续) " user_input

if [ "$user_input" == "yes" ]; then
    if [ -f "$USER_HOME/serv00-webdav/setup_wsgidav.sh" ]; then
        echo "正在运行 ./setup_wsgidav.sh..."
        chmod +x "$USER_HOME/serv00-webdav/setup_wsgidav.sh"
        "$USER_HOME/serv00-webdav/setup_wsgidav.sh"
    else
        echo "未找到 setup_wsgidav.sh 文件，请确认脚本是否已下载到 $USER_HOME/serv00-webdav 目录。"
    fi
else
    echo "您可以稍后手动运行 ./setup_wsgidav.sh 来进行配置。"
fi
