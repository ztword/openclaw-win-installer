# 贡献指南

感谢你有兴趣为这个项目做贡献！

## 如何贡献

### 报告 Bug

1. 先搜索 [已有 Issue](../../issues)，确认没有重复
2. 创建新 Issue，包含以下信息
   - Windows 版本（Win10 / Win11 及具体版本号）
   - 报错的完整截图或日志
   - 你执行到了哪一步
   - 你选择的安装模式（全局 / 源码）

### 提交代码

1. Fork 本仓库
2. 创建你的分支 `git checkout -b feature/your-feature`
3. 提交修改 `git commit -m "feat: 你的改动描述"`
4. 推送分支 `git push origin feature/your-feature`
5. 创建 Pull Request

### Commit 规范

采用 [Conventional Commits](https://www.conventionalcommits.org/) 规范

- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `refactor:` 重构
- `chore:` 杂项

### 脚本修改注意事项

- PowerShell 脚本确保在 Windows PowerShell 5.1 和 PowerShell 7+ 下都能运行
- Bash 脚本确保在 Ubuntu 22.04 和 24.04 下都能运行
- 修改后请自行在干净环境中测试一遍完整流程
- 所有用户可见的输出使用中文

## 行为准则

对人友善。不友善的 Issue 和 PR 会被直接关闭。