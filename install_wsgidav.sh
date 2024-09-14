#!/bin/bash

# 用户目录
USER_HOME="/usr/home/$(whoami)"

# 进入用户目录并创建虚拟环境
cd "$USER_HOME" || exit
if [ ! -d "venv_webdav" ]; then
    virtualenv venv_webdav
fi
source venv_webdav/bin/activate

# 安装PM2
if ! command -v pm2 &> /dev/null; then
    echo "正在安装 PM2..."
    pip install pm2
    pm2 startup
fi

# 安装WsgiDAV和Cheroot
echo "正在安装 WsgiDAV 和 Cheroot..."
pip install wsgidav cheroot python-dotenv

# 创建WsgiDAV配置文件
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

# 创建WebDAV根目录
mkdir -p "$USER_HOME/webdav"

# 使用PM2启动WsgiDAV
echo "通过 PM2 启动 WsgiDAV..."
pm2 start wsgidav -- --config="$WSGIDAV_CONFIG"

# 保存PM2状态
pm2 save

# 设置cron任务在重启后自动启动PM2
(crontab -l 2>/dev/null; echo "@reboot $(which pm2) resurrect") | crontab -

# 提示安装完成
echo "WsgiDAV 安装完成，您可以通过 ./setup_wsgidav.sh 进行进一步配置。"

# 询问用户是否继续执行配置脚本
read -p "是否现在运行 ./setup_wsgidav.sh 进行配置？(输入 'yes' 继续) " user_input

if [ "$user_input" == "yes" ]; then
    if [ -f "$USER_HOME/setup_wsgidav.sh" ]; then
        echo "正在运行 ./setup_wsgidav.sh..."
        chmod +x "$USER_HOME/setup_wsgidav.sh"
        "$USER_HOME/setup_wsgidav.sh"
    else
        echo "未找到 setup_wsgidav.sh 文件，请确认脚本是否已下载到 $USER_HOME 目录。"
    fi
else
    echo "您可以稍后手动运行 ./setup_wsgidav.sh 来进行配置。"
fi
