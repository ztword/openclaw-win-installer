# 常见问题

## 安装相关

### Q，执行 PowerShell 脚本提示"无法加载文件，因为在此系统上禁止运行脚本"

执行以下命令解除限制

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Q，winget 命令不存在
Windows 10 老版本可能没有 winget。两种解决办法

去微软商店搜索 App Installer 安装
手动去 https://git-scm.com/downloads 下载安装 Git，然后重新运行脚本
Q，WSL 安装后重启，Ubuntu 没有自动弹出
手动打开开始菜单搜索 Ubuntu 启动。如果找不到，在管理员 PowerShell 里执行

```PowerShell

wsl --install -d Ubuntu
```
Q，Ubuntu 设置密码时什么都看不见
正常现象。Linux 下输入密码不会显示任何字符，包括星号。直接盲打，打完回车就行。

Q，systemctl 验证失败
确认 /etc/wsl.conf 内容正确，然后在 PowerShell 中执行 wsl --shutdown，等 5 秒，再 wsl 重新进入。

Q，nvm install 报网络错误
国内用户可能需要配置镜像。在 WSL 中执行

```Bash

export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
nvm install 24
```
写入 ~/.bashrc 可永久生效。

Q，pnpm install 卡住不动
正常现象。依赖体积大，下载过程中终端可能没有输出。不要关闭终端，耐心等待。如果超过 2 小时还没动静，Ctrl+C 取消后重新执行 pnpm install。

Q，openclaw command not found
脚本内置了 PATH 自动修复。如果仍然找不到，手动执行

```Bash

export PATH="$(npm prefix -g)/bin:$PATH"
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.bashrc
```
Q，选源码安装后 pnpm ui:build 报错
确认 Node 版本 >= 22。执行 node -v 检查。如果版本不对，执行 nvm use 24。

使用相关
Q，如何从 Windows 浏览器访问 OpenClaw Dashboard
onboard 完成后，Dashboard 默认运行在 localhost 的某个端口。WSL2 的 localhost 和 Windows 是互通的，直接在 Windows 浏览器打开对应地址即可。

Q，如何更新 OpenClaw
全局安装模式

```Bash

npm update -g openclaw
```
源码安装模式

```Bash

cd /mnt/d/openclaw
git pull
pnpm install
pnpm ui:build
pnpm build
```
Q，如何卸载
全局安装模式

```Bash

openclaw gateway stop
npm uninstall -g openclaw
```
源码安装模式

```Bash

cd /mnt/d
rm -rf openclaw
```
如果要彻底移除 WSL，在管理员 PowerShell 中执行

```PowerShell

wsl --unregister Ubuntu

```