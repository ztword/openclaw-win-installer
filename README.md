# openclaw-win-installer

一键在 Windows 上通过 WSL 环境安装/运行 OpenClaw 的辅助项目。

## 快速开始

1. 以管理员身份打开 PowerShell
2. 运行：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\setup-wsl.ps1
```

3. 进入 WSL 后运行：

```bash
bash ./scripts/install-openclaw.sh
```

## 目录结构

- scripts：安装与环境初始化脚本
- assets：文档所用图片与演示动图
- docs：FAQ 与安全相关文档
