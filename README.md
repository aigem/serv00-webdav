

---

# 一键将 Serv00 变为免费私人网盘（WebDAV）: WsgiDAV 安装与部署指南

## 1. 简介

**WsgiDAV** 是一个基于 Python 的可扩展 WebDAV 服务器，支持 SSL，并可以运行在 Linux、macOS 和 Windows 系统上。这个安装脚本帮助您在 FreeBSD 系统（如 serv00 免费 VPS）上快速部署 WsgiDAV，并确保服务在系统重启后自动恢复。

通过本指南，您将能够轻松在 serv00 VPS 上设置 WebDAV 服务，使其成为您的免费私人网盘，并提供文件共享、用户认证、SSL 支持等功能。

### 功能亮点：
- 提供 WebDAV 文件共享服务
- 支持用户认证和 SSL
- 使用 PM2 进行进程管理，确保服务持久运行并在系统重启后自动恢复
- 一键安装，快速部署

---

## 2. 系统要求

- **FreeBSD 系统**（如 serv00 提供的 VPS）
- [免费注册Serv00](https://www.serv00.com/)

### 2.1 使用 SSH 登录
通过以下命令登录到您的 serv00 VPS：
```bash
ssh 用户名@sX.serv00.com
```
其中 `sX.serv00.com` 是您的服务器地址，您可以在 serv00 后台找到相应的 IP。

---

## 3. 安装与部署步骤

### 3.1 一键安装

1. **克隆并运行安装脚本**

首先，使用以下命令克隆 GitHub 仓库并运行安装脚本：

```bash
git clone https://github.com/aigem/serv00-webdav.git
cd serv00-webdav
chmod +x install_wsgidav.sh
./install_wsgidav.sh
```

2. **脚本功能说明**

在脚本运行期间，您将被提示输入以下信息：
- **WebDAV 服务端口号**：脚本会引导您开通或输入已开放的端口号。此端口将用于访问您的 WebDAV 服务。
- **用户名和密码**：设置 WebDAV 服务的访问用户名和密码。

脚本会自动安装以下组件：
- **PM2**：用于管理 WsgiDAV 进程，确保其在后台持续运行。
- **WsgiDAV 和 Cheroot**：WsgiDAV 用于提供 WebDAV 服务，Cheroot 是 Web 服务器。

**目录结构：**
- **根目录**：`/usr/home/用户名/webdav/dav` 将作为 WebDAV 服务的根目录，您可以将文件存储在此目录下。

---

## 4. 自动化任务管理

### 4.1 使用 PM2 管理 WsgiDAV

**PM2** 是一个进程管理工具，可以确保 WsgiDAV 在后台运行并在系统重启后自动恢复。通过 `PM2`，您可以轻松地管理、重启或停止 WsgiDAV 服务。

**常用 PM2 命令**：
- **启动 WsgiDAV 服务**：
  ```bash
  pm2 start wsgidav --interpreter /usr/home/用户名/venv_webdav/bin/python -- --config=/usr/home/用户名/wsgidav.yaml
  ```
- **查看 PM2 中的所有进程**：
  ```bash
  pm2 list
  ```
- **重启所有进程**：
  ```bash
  pm2 restart all
  ```

### 4.2 自动重启设置

为了确保 WsgiDAV 在系统重启后能自动恢复，安装脚本已经通过 `crontab` 添加了自动恢复任务：
```bash
@reboot pm2 resurrect
```

您可以通过以下命令查看当前的 `crontab` 任务：
```bash
crontab -l
```

---

## 5. 访问您的 WebDAV 服务

当安装完成后，您可以通过以下地址访问您的 WebDAV 服务：
```
https://你的用户名.serv00.net
```

请使用您在安装过程中设置的用户名和密码进行登录。

---

## 6. 常见问题

1. **如何更改 WebDAV 服务的端口？**
   - 在 `wsgidav.yaml` 配置文件中，修改 `port` 字段，然后重启服务：
     ```bash
     pm2 restart all
     ```

2. **如何查看 WsgiDAV 日志？**
   - 使用以下命令查看 PM2 的日志输出：
     ```bash
     pm2 logs
     ```

3. **如何手动停止 WsgiDAV 服务？**
   - 使用以下命令停止服务：
     ```bash
     pm2 stop wsgidav
     ```

---

## 7. 参考资料

- [WsgiDAV 官方文档](https://wsgidav.readthedocs.io/en/latest/)
- [PM2 官方文档](https://pm2.keymetrics.io/docs/usage/quick-start/)
  
---

通过此指南，您已经成功在 serv00 上部署了 WsgiDAV，并通过 PM2 确保其持久运行。您可以随时通过修改配置或使用 PM2 命令管理服务，享受便捷的 WebDAV 文件共享功能。如果有任何问题，欢迎查阅官方文档或社区论坛。

