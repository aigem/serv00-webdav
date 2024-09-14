# 一键让serv00变你的免费私人网盘(webdav): WsgiDAV 安装与部署指南

## 1. 简介

**WsgiDAV** 是一个基于 Python 的可扩展 WebDAV 服务器，支持 SSL，可作为独立命令行脚本运行在 Linux、OSX、和 Windows 系统上。

本安装脚本帮助您在 FreeBSD 系统（如 serv00 免费 VPS）上快速部署 WsgiDAV，并确保服务在系统重启后自动恢复。一键让serv00变你的免费私人网盘(webdav)。

**主要功能：**
- 提供 WebDAV 文件共享服务
- 支持简单的用户认证
- 使用 PM2 管理服务，确保服务持久运行

## 2. 系统需求

- **Python 3**（如果系统没有，请提前安装）
- **pip3**（Python 包管理器）
- 用户对 `/usr/home/用户名` 文件夹有读写权限

## 3. 部署步骤

### 3.1 安装 WsgiDAV

1. **下载并运行安装脚本**  
   首先，您需要通过以下命令下载并执行安装脚本，它将自动为您安装所需的依赖项，并配置 WsgiDAV 服务：
   ```bash
   curl -O https://example.com/install_wsgidav.sh
   chmod +x install_wsgidav.sh
   ./install_wsgidav.sh
   ```

2. **脚本说明**  
   - 该脚本将自动安装 PM2 和 WsgiDAV。
   - 默认端口为 8080，根目录为 `/usr/home/用户名/webdav-root`。
   - 服务启动后，PM2 会自动管理 WsgiDAV 服务，确保其在系统重启后恢复。

### 3.2 配置 WsgiDAV

为了更好地控制您的 WebDAV 服务器，您可以运行以下配置脚本来更改端口、用户名和密码：

1. **下载并运行配置脚本**：
   ```bash
   curl -O https://example.com/setup_wsgidav.sh
   chmod +x setup_wsgidav.sh
   ./setup_wsgidav.sh
   ```

2. **脚本说明**  
   - 脚本将提示您输入自定义的端口号、用户名和密码。  
   - 所有更改将在 WsgiDAV 配置文件中生效，并且服务会自动重启以应用这些更改。

### 3.3 验证服务是否成功运行

1. 使用浏览器访问 WebDAV 服务：
   ```
   http://your-server-ip:your-port
   ```
   例如，如果您将端口设置为 8080，使用 `http://your-server-ip:8080` 进行访问。

2. 输入您在配置步骤中设置的用户名和密码。

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

- **端口号冲突**：如果默认的端口号 8080 被其他服务占用，请在配置脚本中修改为一个空闲端口，您可以使用以下命令查看系统已有的端口号：
   ```bash
   sockstat -4 -l
   ```
- **安全性**：建议在生产环境中启用 SSL 以加密数据传输。关于如何配置 SSL，请参考 [WsgiDAV 官方文档](https://wsgidav.readthedocs.io/en/latest/user_guide_configure.html#ssl-support)。
- **权限问题**：由于您在 `serv00` VPS 中没有 root 权限，所有文件和脚本都只能放在 `/usr/home/用户名` 目录下，确保服务在该目录中运行。

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


### 说明：

1. **分步骤部署**：文档中将安装和配置步骤进行了清晰的分离，使不同用户可以根据需求快速部署或调整。
2. **自动化任务设置**：通过 PM2 和 cron 的结合，文档确保了系统重启后的自动恢复功能。
3. **详细的注意事项**：包括端口号检查、SSL 安全建议、权限限制等信息，确保用户在不同环境下的兼容性。

这样，用户不仅能快速部署 WsgiDAV，还能灵活调整配置，确保服务稳定运行。
