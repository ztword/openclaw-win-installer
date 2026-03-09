#Requires -RunAsAdministrator
# ============================================
# 惑弟儿出品 - OpenClaw WSL 环境一键部署
# 在 Windows 宿主机以管理员身份执行
# ============================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " OpenClaw WSL 环境部署脚本" -ForegroundColor Cyan
Write-Host " 惑弟儿出品" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---------- 检测 Git ----------
Write-Host "[1/4] 检测 Git..." -ForegroundColor Yellow
$gitPath = Get-Command git -ErrorAction SilentlyContinue
if ($gitPath) {
    $gitVersion = git --version
    Write-Host "  Git 已安装，$gitVersion" -ForegroundColor Green
} else {
    Write-Host "  Git 未安装，正在通过 winget 安装..." -ForegroundColor Yellow
    try {
        winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    } catch {
        Write-Host "  winget 安装 Git 失败" -ForegroundColor Red
        Write-Host "  请手动下载安装 https://git-scm.com/downloads" -ForegroundColor Red
        Write-Host "  安装完成后重新运行此脚本" -ForegroundColor Red
        pause
        exit 1
    }
    # 刷新 PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $verifyGit = Get-Command git -ErrorAction SilentlyContinue
    if (-not $verifyGit) {
        Write-Host "  Git 安装后仍未检测到，请关闭此窗口重新打开 PowerShell 后再试" -ForegroundColor Red
        pause
        exit 1
    }
    Write-Host "  Git 安装完成" -ForegroundColor Green
}

# ---------- 检测 WSL ----------
Write-Host "[2/4] 检测 WSL..." -ForegroundColor Yellow
$wslList = $null
try {
    $wslList = wsl --list --quiet 2>&1
} catch {}

$hasUbuntu = $false
if ($wslList) {
    foreach ($line in $wslList) {
        if ($line -match "Ubuntu") {
            $hasUbuntu = $true
            break
        }
    }
}

if (-not $hasUbuntu) {
    Write-Host "  WSL 未安装或未检测到 Ubuntu，正在安装..." -ForegroundColor Yellow
    wsl --install -d Ubuntu
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host " WSL + Ubuntu 安装完成，需要重启电脑！" -ForegroundColor Red
    Write-Host "" -ForegroundColor Red
    Write-Host " 重启后 Ubuntu 会自动弹出" -ForegroundColor Red
    Write-Host " 按提示设置用户名和密码" -ForegroundColor Red
    Write-Host " 密码输入时看不见，盲打就行" -ForegroundColor Red
    Write-Host "" -ForegroundColor Red
    Write-Host " 设置完成后，重新以管理员身份" -ForegroundColor Red
    Write-Host " 运行此脚本（第二次）" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    $restart = Read-Host "是否现在重启电脑？(y/n)"
    if ($restart -eq "y") { Restart-Computer -Force }
    exit 0
} else {
    Write-Host "  WSL + Ubuntu 已安装" -ForegroundColor Green
    wsl --list --verbose
}

# ---------- 配置 systemd ----------
Write-Host "[3/4] 配置 WSL systemd..." -ForegroundColor Yellow

# 创建临时脚本，避免 PowerShell here-string 引号转义问题
$tempScript = [System.IO.Path]::GetTempFileName() + ".sh"
@'
#!/bin/bash
if grep -q 'systemd=true' /etc/wsl.conf 2>/dev/null; then
    echo "  systemd 已配置，跳过"
else
    cat > /etc/wsl.conf << 'WSLEOF'
[boot]
systemd=true
[interop]
enabled=true
appendWindowsPath=true
WSLEOF
    echo "  wsl.conf 写入完成"
fi
'@ | Set-Content -Path $tempScript -Encoding UTF8 -NoNewline

# 将 Windows 路径转为 WSL 路径
$wslTempPath = wsl wslpath -u ($tempScript -replace '\\','/')
wsl -u root -e bash $wslTempPath
Remove-Item $tempScript -ErrorAction SilentlyContinue

Write-Host "  正在重启 WSL 以使 systemd 生效..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 3

# 验证 systemd
$systemdCheck = wsl -e bash -lc "systemctl --user is-system-running 2>/dev/null || echo 'failed'"
if ($systemdCheck -match "running|degraded|starting") {
    Write-Host "  systemd 验证通过" -ForegroundColor Green
} else {
    Write-Host "  systemd 可能未正常启动，状态为 $systemdCheck" -ForegroundColor Yellow
    Write-Host "  如果后续安装正常则可忽略此警告" -ForegroundColor Yellow
}

# ---------- 创建桌面快捷方式 ----------
Write-Host "[4/4] 创建桌面快捷方式..." -ForegroundColor Yellow
$Desktop = [Environment]::GetFolderPath("Desktop")

# 用 bash -lc 确保登录 shell 加载 nvm PATH
@"
@echo off
title OpenClaw TUI
wsl -e bash -lc "openclaw tui"
pause
"@ | Out-File "$Desktop\OpenClaw-TUI.bat" -Encoding ASCII

@"
@echo off
title OpenClaw Dashboard
wsl -e bash -lc "openclaw dashboard"
pause
"@ | Out-File "$Desktop\OpenClaw-Dashboard.bat" -Encoding ASCII

Write-Host "  桌面快捷方式已创建" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " WSL 环境就绪！" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host " 接下来请进入 WSL 执行第二步" -ForegroundColor Green
Write-Host " 1. 在此窗口输入 wsl 回车" -ForegroundColor Green
Write-Host " 2. 运行 bash ~/install-openclaw.sh" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
pause