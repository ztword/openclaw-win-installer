
---

## 📄 docs/SECURITY.md

```markdown
# 安全说明

## 脚本安全

本项目的脚本会执行以下操作，请在运行前了解

1. **setup-wsl.ps1**（需要管理员权限）
   - 通过 winget 安装 Git
   - 启用 WSL 功能并安装 Ubuntu
   - 写入 `/etc/wsl.conf` 配置 systemd
   - 在桌面创建 .bat 快捷方式

2. **install-openclaw.sh**（需要 sudo 权限安装系统包）
   - apt-get install 基础构建工具
   - 安装 nvm 和 Node.js
   - npm install -g 或 git clone 安装 OpenClaw

所有操作均可在脚本源码中审查。建议运行前阅读脚本内容。

## nvm 安全

脚本强制使用 nvm v0.40.4 或更高版本。v0.40.3 及以下版本存在命令注入漏洞（CVE-2026-1665），脚本会自动检测并升级。

## OpenClaw 安全

- OpenClaw 是实验性软件，官方文档明确声明其安全性尚未经过完整审计
- **不要以 root 用户运行 OpenClaw**
- **不要将 Gateway 直接暴露到公网**，建议使用 Tailscale、Cloudflare Tunnel 等工具
- **谨慎安装第三方 Skills**，社区 Skills 安全审核不足，使用前先审查源码
- 只从官方仓库 `github.com/openclaw/openclaw` 获取代码，搜索引擎上存在投放恶意安装程序的案例

## 报告漏洞

如果你发现本项目脚本中存在安全问题，请通过 Issue 报告，或发送邮件至 [你的邮箱]。