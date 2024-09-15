# 一键让serv00变你的免费私人网盘(webdav): WsgiDAV 安装与部署指南

## 1. 简介

**WsgiDAV** 是一个基于 Python 的可扩展 WebDAV 服务器，支持 SSL，可作为独立命令行脚本运行在 Linux、OSX、和 Windows 系统上。

本安装脚本帮助您在 FreeBSD 系统（如 serv00 免费 VPS）上快速部署 WsgiDAV，并确保服务在系统重启后自动恢复。一键让serv00变你的免费私人网盘(webdav)。

**主要功能：**
- 提供 WebDAV 文件共享服务
- 支持简单的用户认证
- 使用 PM2 管理服务，确保服务持久运行
- 一键安装

## 2. 系统需求

- **serv00**（免费注册，现在相对没之前容易，因为需要好点的IP）

### 2.1 ssh登录
   ```bash
   ssh 你的用户名@sX.serv00.com 或IP
   ```
IP在后台WWW websites中查看，有两个。

## 3. 部署步骤

### 3.1 一键安装

1. **下载并运行安装脚本**  
   首先，您需要通过以下命令下载并执行安装脚本，它将自动为您安装所需的依赖项，并配置 WsgiDAV 服务：
   ```bash
   git clone https://github.com/aigem/serv00-webdav.git
   cd serv00-webdav
   chmod +x install_wsgidav.sh
   ./install_wsgidav.sh
   ```

2. **脚本说明**  
   - 该脚本将自动安装 PM2 和 WsgiDAV。
   - 设置阶段选择你的端口，根目录为 `/usr/home/用户名/webdav`。
   - 服务启动后，PM2 会自动管理 WsgiDAV 服务，确保其在系统重启后恢复。

## 4. 自动化任务

### 4.1 PM2 自动恢复

为了确保系统重启后服务能自动恢复，安装脚本中已经通过 `crontab` 设置了自动启动 PM2 的任务。

您可以查看当前的 `crontab` 任务：
```bash
crontab -l
```
输出应包含：
```bash
@reboot /usr/home/$(whoami)/.local/bin/pm2 resurrect
```

### 4.2 自定义 Cron 任务

如需自定义其他任务，您可以编辑自己的 `crontab`：
```bash
crontab -e
```

## 5. 注意事项

- **端口号**：在serv00管理后台侧边栏进行Port reservation，增加端口，设置阶段请填入这个端口。

## 6. 常见问题

1. **如何重启 WsgiDAV 服务？**
   - 运行以下命令重启 PM2 中的所有服务：
     ```bash
     pm2 restart all
     ```

2. **如何查看 WsgiDAV 的运行日志？**
   - 使用以下命令查看 PM2 的日志：
     ```bash
     pm2 logs
     ```

3. **如何停止 WsgiDAV 服务？**
   - 使用以下命令停止服务：
     ```bash
     pm2 stop wsgidav
     ```

## 7. 参考资料

- [WsgiDAV 官方文档](https://wsgidav.readthedocs.io/en/latest/)
- [PM2 官方文档](https://pm2.keymetrics.io/docs/usage/quick-start/)

## 8. 结语

通过本指南，您已经成功在 FreeBSD 系统上部署了 WsgiDAV 服务，并通过 PM2 保证其持久运行。希望这能帮助您方便地进行文件共享和管理。若有任何问题或建议，欢迎通过官方文档或社区寻求帮助。
