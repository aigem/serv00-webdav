#!/bin/bash

# 用户目录
USER_HOME="/usr/home/$(whoami)"
CONFIG_FILE="$USER_HOME/wsgidav.yaml"

# 检查 PM2 是否保存了应用状态
echo "当前 PM2 中保存的应用状态:"
pm2 list

# 提示用户输入端口号
echo "请输入 WsgiDAV 的端口号 (默认: 8080):"
read -r WSGIDAV_PORT

# 提示用户输入用户名和密码
echo "请输入 WebDAV 的用户名 (默认: user):"
read -r WEBDAV_USER
echo "请输入 WebDAV 的密码 (默认: password):"
read -sr WEBDAV_PASSWORD

# 更新配置文件
sed -i "" "s/port: 8080/port: $WSGIDAV_PORT/" "$CONFIG_FILE"
sed -i "" "s/user: password/$WEBDAV_USER: $WEBDAV_PASSWORD/" "$CONFIG_FILE"

# 重启PM2以应用更改
pm2 restart all

echo "WsgiDAV 配置已更新，当前服务运行在端口: $WSGIDAV_PORT."
