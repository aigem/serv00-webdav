#!/bin/bash

# 用户目录
USER_HOME="/usr/home/$(whoami)"
VENV_PATH="$USER_HOME/venv_webdav"
CONFIG_FILE="$USER_HOME/webdav/wsgidav.yaml"
BASH_PROFILE="$USER_HOME/.bash_profile"

# 切换到用户目录
cd "$USER_HOME"

# 创建 WebDAV 等目录
mkdir -p "$USER_HOME/webdav"
mkdir -p "$USER_HOME/webdav/dav"

# 提示用户输入 WsgiDAV 的端口号或开通新端口号
echo "请输入 WebDAV 的端口号 (需要你开通):"
echo "你已开通的端口号为: "
devil port list

read -p "请输入你已开通的端口号，或输入 'add' 来开通一个新的端口号 (总共最多3个): " user_input

# 判断用户输入
if [[ "$user_input" == "add" ]]; then
    # 自动为用户开通一个端口 (随机)
    devil port add tcp random
    # 再次获取开通的端口列表
    echo "端口开通成功: "
    devil port list
    echo "请输入生成的端口号: "
    read -r WSGIDAV_PORT
    if [[ "$WSGIDAV_PORT" -lt 1024 || "$WSGIDAV_PORT" -gt 65535 ]]; then
        echo "端口号不在有效范围内 (1024-65535)。请重新输入。"
        exit 1
    fi

else
    # 用户自己输入端口号
    WSGIDAV_PORT="$user_input"
    if [[ "$WSGIDAV_PORT" -lt 1024 || "$WSGIDAV_PORT" -gt 65535 ]]; then
        echo "端口号不在有效范围内 (1024-65535)。请重新输入。"
        exit 1
    fi

fi

echo "请输入 WebDAV 的用户名 (默认: user):"
read -r WEBDAV_USER
WEBDAV_USER=${WEBDAV_USER:-user}  # 如果未输入值，默认使用 'user'

echo "请输入 WebDAV 的密码 (默认: password):"
read -sr WEBDAV_PASSWORD
WEBDAV_PASSWORD=${WEBDAV_PASSWORD:-password}  # 如果未输入值，默认使用 'password'

# 生成 WsgiDAV 配置文件

cat <<EOF > "$CONFIG_FILE"
# WsgiDAV configuration file
host: 0.0.0.0
port: $WSGIDAV_PORT
root: $USER_HOME/webdav
server: "cheroot"
mount_path: null
provider_mapping:
  "/": "$USER_HOME/webdav"
fs_dav_provider:
    follow_symlinks: false
http_authenticator:
  domain_controller: wsgidav.dc.simple_dc.SimpleDomainController
  accept_basic: true
  accept_digest: true
  default_to_digest: true
simple_dc:
  user_mapping:
    "*":
      "$WEBDAV_USER": 
        password: "$WEBDAV_PASSWORD"
    '/pub': true
hotfixes:
  re_encode_path_info: true
add_header_MS_Author_Via: true

# cheroot 服务器参数
server_args:
  numthreads: 8
  request_queue_size: 5
  timeout: 10
EOF

# 网站指向部分
echo "现需要修改你的网站($(whoami).serv00.net)指向 $WSGIDAV_PORT，并重置网站。"
echo "警告：这将会重置网站（删除网站所有内容）！"
read -p "请输入 'yes' 来重置网站 ($(whoami).serv00.net) 并指向 $WSGIDAV_PORT，或输入 'no' 来退出自动设置：" user_input

if [[ "$user_input" == "yes" ]]; then
    echo "开始重置网站..."

    # 删除旧域名
    DELETE_OUTPUT=$(devil www del "$(whoami).serv00.net")

    if echo "$DELETE_OUTPUT" | grep -q "Domain deleted"; then
        echo "网站删除成功: $(whoami).serv00.net"
        ADD_OUTPUT=$(devil www add "$(whoami).serv00.net" proxy localhost "$WSGIDAV_PORT")

        if echo "$ADD_OUTPUT" | grep -q "Domain added succesfully"; then
            echo "网站成功重置并指向端口 $WSGIDAV_PORT。"
        else
            echo "新建网站失败，请之后检查。不影响安装"
        fi
    else
        echo "删除网站失败，请检查。"
    fi
else
    echo "跳过网站设置，之后进行人工设置。"
fi

# 安装 PM2 (使用 npm)
if [ ! -f "$USER_HOME/node_modules/pm2/bin/pm2" ]; then
    echo "正在安装 PM2..."
    npm install pm2
else
    echo "PM2 已安装。"
fi

# 删除 .bash_profile 中可能存在的旧条目
sed -i '' '/export PATH=".*\/node_modules\/pm2\/bin:$PATH"/d' "$BASH_PROFILE"
sed -i '' '/export CFLAGS="-I\/usr\/local\/include"/d' "$BASH_PROFILE"
sed -i '' '/export CXXFLAGS="-I\/usr\/local\/include"/d' "$BASH_PROFILE"

# 添加新的环境变量条目到 .bash_profile
echo "export PATH=\"$USER_HOME/node_modules/pm2/bin:\$PATH\"" >> "$BASH_PROFILE"
echo 'export CFLAGS="-I/usr/local/include"' >> "$BASH_PROFILE"
echo 'export CXXFLAGS="-I/usr/local/include"' >> "$BASH_PROFILE"

# 重新加载 .bash_profile
source "$BASH_PROFILE"

# 创建并激活虚拟环境
if [ ! -d "$VENV_PATH" ]; then
    echo "创建虚拟环境..."
    virtualenv "$VENV_PATH"
fi

# 激活虚拟环境
echo "激活虚拟环境: $VENV_PATH"
source "$VENV_PATH/bin/activate"

if [ -z "$VIRTUAL_ENV" ]; then
    echo "虚拟环境激活失败，请检查配置。"
    exit 1
else
    echo "虚拟环境已激活: $VIRTUAL_ENV"
fi

# 安装 WsgiDAV 和 Cheroot
echo "安装 WsgiDAV 和 Cheroot...(可选lxml)"
pip install wsgidav cheroot

# 使用 PM2 启动 WsgiDAV
echo "使用 PM2 启动 WsgiDAV..."
pm2 start wsgidav --interpreter "$VENV_PATH/bin/python" -- --config="$CONFIG_FILE"

# 检查 WsgiDAV 是否启动成功
if pm2 list | grep -q "wsgidav"; then
    echo "WsgiDAV 已成功启动。"
else
    echo "WsgiDAV 启动失败，请检查配置。"
    exit 1
fi

# 保存 PM2 状态
pm2 save

# 设置 cron 任务在重启后自动启动 PM2
(crontab -l 2>/dev/null; echo "@reboot pm2 resurrect") | crontab -

# 系统必要设置为ON
devil binexec on

# 提示安装完成
echo "WsgiDAV 安装完成并已启动，当前服务运行在端口: $WSGIDAV_PORT"
echo 'WsgiDAV版本：$VENV_PATH/bin/wsgidav -V'

if [ -f "$USER_HOME/domains/$(whoami).serv00.net/public_html/index.html" ]; then
    rm "$USER_HOME/domains/$(whoami).serv00.net/public_html/index.html"
fi

# 生成 info文件
INFO_FILE="$USER_HOME/domains/$(whoami).serv00.net/public_html/index.html"

cat <<EOF > "$INFO_FILE"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WsgiDAV 安装成功</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        p {
            line-height: 1.6;
            color: #666;
        }
        a {
            color: #0066cc;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>WebDAV 已成功安装</h1>
        <p>恭喜！WsgiDAV 已成功安装并运行在 <strong>$(whoami).serv00.net</strong> 上。当前的 WebDAV 服务正在端口 <strong>$WSGIDAV_PORT</strong> 上运行。</p>
        <h2> <a href="/dav" target="_blank">打 开 网 盘</a></h2>
        <h2>主要功能</h2>
        <ul>
            <li>一键安装 WebDAV 文件共享服务</li>
            <li>支持简单的用户认证</li>
            <li>使用 PM2 管理服务，确保其在系统重启后自动恢复</li>
        </ul>

        <h2>进一步阅读</h2>
        <p>欲了解更多详细说明和安装步骤，请访问 GitHub 仓库：</p>
        <p><a href="https://github.com/aigem/serv00-webdav" target="_blank">WsgiDAV GitHub 仓库</a></p>

        <h2>常见问题</h2>
        <p>1. 如何重启 WsgiDAV 服务？</p>
        <p>使用以下命令重启 PM2 中的所有服务：</p>
        <pre><code>pm2 restart all</code></pre>

        <p>2. 如何查看 WsgiDAV 的运行日志？</p>
        <p>使用以下命令查看 PM2 的日志：</p>
        <pre><code>pm2 logs</code></pre>

        <p>3. 如何停止 WsgiDAV 服务？</p>
        <p>使用以下命令停止服务：</p>
        <pre><code>pm2 stop wsgidav</code></pre>
    </div>
</body>
</html>
EOF

# 重启 PM2 以应用更改
pm2 restart all

echo "Happy Webdav. 请从【 https://$(whoami).serv00.net 】开始"

cd