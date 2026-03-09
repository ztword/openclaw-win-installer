<div align="center">

# 🦞 OpenClaw Win Installer

**一键在 Windows 上安装 OpenClaw**

基于 WSL2 + Ubuntu，两个脚本，从零到跑通。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![GitHub Stars](https://img.shields.io/github/stars/yourname/openclaw-win-installer?style=social)](https://github.com/yourname/openclaw-win-installer)

[快速开始](#-快速开始) · [常见问题](docs/FAQ.md) · [安全说明](docs/SECURITY.md) · [English](README_EN.md)

</div>

---

## 这是什么

每天都有人问我同一个问题，怎么在 Windows 上装 OpenClaw。

OpenClaw 官方推荐 Windows 用户通过 WSL 安装。但从零开始配 WSL、装 Node、克隆仓库、构建项目，整个流程散落在各种文档里，踩坑无数。

这个项目把所有步骤打包成两个脚本。第一个在 PowerShell 跑，搞定 WSL 环境。第二个在 Ubuntu 里跑，搞定 OpenClaw 安装。全程自动化，该装的装，该配的配，该检测的检测。

惑弟儿出品。

## ✨ 特性

- **两步完成**，PowerShell 脚本搞定 WSL，Bash 脚本搞定 OpenClaw
- **自动检测**，Git、WSL、Node、nvm 全部自动检测，装过的跳过，没装的补上
- **双模式安装**，支持全局安装（快速上手）和源码安装（适合开发者）
- **安全校验**，nvm 版本安全检测，自动规避 CVE-2026-1665 命令注入漏洞
- **PATH 自修复**，openclaw 命令找不到时自动修复 PATH
- **桌面快捷方式**，自动创建 OpenClaw TUI 和 Dashboard 的桌面快捷方式
- **中文全程提示**，每一步都有清晰的中文输出，不用猜

## 📋 环境要求

| 项目 | 要求 |
|------|------|
| 操作系统 | Windows 10 (2004+) 或 Windows 11 |
| 架构 | x86_64 / ARM64 |
| 磁盘空间 | 至少 5GB 可用空间 |
| 网络 | 能访问 GitHub 和 npm registry |

不需要提前安装任何东西。脚本会自动处理 Git、WSL、Node、pnpm 的安装。

## 🚀 快速开始

整个流程分两步。

### 第一步，Windows 宿主机

1. 下载本项目

```powershell
git clone https://github.com/yourname/openclaw-win-installer.git
```
如果还没装 Git，直接点击页面上方绿色的 Code → Download ZIP 解压即可。

2.右键 scripts/setup-wsl.ps1，选择 以管理员身份运行
或者在管理员 PowerShell 中执行

```PowerShell

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
cd openclaw-win-installer\scripts
.\setup-wsl.ps1
```
3.如果是首次安装 WSL，脚本会提示重启电脑。重启后 Ubuntu 自动弹出，设置用户名和密码（密码看不见，盲打），然后再运行一次 setup-wsl.ps1


第二步，WSL Ubuntu 内
在 PowerShell 中输入 wsl 回车进入 Ubuntu

执行安装脚本

```Bash

# 如果项目在 D 盘
cd /mnt/d/openclaw-win-installer/scripts
# 如果项目在 C 盘用户目录
# cd /mnt/c/Users/你的用户名/Downloads/openclaw-win-installer/scripts

chmod +x install-openclaw.sh
bash install-openclaw.sh
```
脚本会让你选择安装方式
选项	说明	适合谁
1 - 全局安装	npm install -g，快，开箱即用	大多数用户
2 - 源码安装	git clone + 构建，可以改代码	开发者
跟着 onboard 向导配置 LLM、API Key、消息渠道，完事
一行命令版（懒人专用）
如果你已经有 WSL + Ubuntu 环境，可以跳过第一步，直接在 Ubuntu 里执行

```Bash

curl -fsSL https://raw.githubusercontent.com/yourname/openclaw-win-installer/main/scripts/install-openclaw.sh | bash
```
📸 效果演示
<details> <summary>点击展开截图</summary>
PowerShell 脚本执行效果
<!-- ![step1](assets/step1-git.png) -->
截图待补充

WSL 安装过程
<!-- ![step2](assets/step2-wsl.png) -->
截图待补充

OpenClaw onboard 向导
<!-- ![step6](assets/step6-onboard.png) -->
截图待补充

</details>
🔧 安装后常用命令
全局安装模式

```Bash

openclaw gateway status     # 查看网关状态
openclaw dashboard          # 打开控制面板
openclaw tui                # 终端交互界面
openclaw doctor             # 健康检查
openclaw logs --follow      # 实时日志
```
源码安装模式（需要先 cd 到项目目录）

```Bash

cd /mnt/d/openclaw
pnpm openclaw gateway status
pnpm openclaw dashboard
pnpm openclaw tui
pnpm openclaw doctor
```
🐛 常见问题
详见 FAQ 文档，这里列几个高频的

Q，脚本提示 winget 不可用怎么办 A，Windows 10 老版本可能没有 winget。去微软商店搜 App Installer 安装即可。或者手动安装 Git 后重新运行脚本。

Q，WSL 安装后重启电脑，Ubuntu 没有自动弹出 A，手动打开开始菜单搜 Ubuntu 启动。如果找不到，在 PowerShell 里执行 wsl --install -d Ubuntu 再试。

Q，pnpm install 卡住不动了 A，正常现象。依赖比较大，看起来卡住其实还在下载。不要关闭终端，等它自己完成。

Q，openclaw 命令提示 command not found A，脚本已内置 PATH 自动修复。如果仍然找不到，手动执行 export PATH="$(npm prefix -g)/bin:$PATH" 然后写入 ~/.bashrc。

⚠️ 安全提醒
只从官方仓库 github.com/openclaw/openclaw 获取 OpenClaw 源码
不要以 root 用户运行 OpenClaw
不要将 Gateway 直接暴露到公网，建议使用 Tailscale 等工具做内网穿透
谨慎安装第三方 Skills，使用前先审查源码
详细安全说明见 SECURITY.md
🤝 贡献
欢迎提 Issue 和 PR。详见 CONTRIBUTING.md。

📄 许可证
MIT License

本项目是社区工具，与 OpenClaw 官方无关。

💬 联系
如果觉得有用，点个 Star ⭐ 就是最大的支持。

有问题开 Issue，不要私信问我了。