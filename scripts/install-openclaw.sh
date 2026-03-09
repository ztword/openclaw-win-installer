#!/usr/bin/env bash
set -euo pipefail

# ============================================
# 惑弟儿出品 - OpenClaw 一键安装脚本
# 在 WSL Ubuntu 内执行
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_err()   { echo -e "${RED}[ERROR]${NC} $*"; }

echo ""
echo -e "${CYAN}========================================"
echo " OpenClaw 一键安装脚本"
echo " 惑弟儿出品"
echo -e "========================================${NC}"
echo ""

# ---------- 基础依赖 ----------
log_info "[1/6] 安装系统基础依赖..."
sudo apt-get update -qq
sudo apt-get install -y -qq curl git build-essential ca-certificates
log_ok "基础依赖就绪"

# ---------- 安装 nvm ----------
log_info "[2/6] 安装 nvm..."

# nvm v0.40.3 及以下版本存在命令注入漏洞 CVE-2026-1665
# 必须使用 v0.40.4 或更高版本
NVM_VERSION="v0.40.4"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    \. "$NVM_DIR/nvm.sh"
    # 检查已安装的 nvm 版本是否满足安全要求
    INSTALLED_NVM_VER=$(nvm --version 2>/dev/null || echo "0.0.0")
    if [[ "$(printf '%s\n' "0.40.4" "$INSTALLED_NVM_VER" | sort -V | head -n1)" == "0.40.4" ]]; then
        log_ok "nvm $INSTALLED_NVM_VER 已安装且版本安全，跳过"
    else
        log_warn "nvm $INSTALLED_NVM_VER 存在安全漏洞(CVE-2026-1665)，正在升级到 ${NVM_VERSION}..."
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
        \. "$NVM_DIR/nvm.sh"
    fi
else
    log_info "正在安装 nvm ${NVM_VERSION}..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

# 加载 nvm
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 验证 nvm 是否可用（nvm 是 shell function，不能用 command -v）
if ! type nvm &>/dev/null; then
    log_err "nvm 加载失败"
    log_err "请手动执行以下命令后重新运行此脚本"
    echo '  export NVM_DIR="$HOME/.nvm"'
    echo '  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    exit 1
fi
log_ok "nvm $(nvm --version) 就绪"

# ---------- 安装 Node.js ----------
log_info "[3/6] 安装 Node.js..."

# OpenClaw 要求 Node 22+
# Node 24 是当前 Active LTS（代号 Krypton），支持到 2028-04-30
# Node 22 是 Maintenance LTS，支持到 2027-04-30
# 默认安装 Node 24，你也可以改成 22
NODE_MAJOR=24

CURRENT_NODE=$(node -v 2>/dev/null || echo "none")
if [[ "$CURRENT_NODE" == "none" ]]; then
    log_info "正在安装 Node.js ${NODE_MAJOR}..."
    nvm install "${NODE_MAJOR}"
    nvm alias default "${NODE_MAJOR}"
else
    CURRENT_MAJOR=$(echo "$CURRENT_NODE" | sed 's/v//' | cut -d. -f1)
    if [ "$CURRENT_MAJOR" -ge 22 ]; then
        log_ok "Node.js ${CURRENT_NODE} 已满足要求（>= 22），跳过"
    else
        log_warn "当前 Node.js ${CURRENT_NODE} 版本过低，正在安装 ${NODE_MAJOR}..."
        nvm install "${NODE_MAJOR}"
        nvm alias default "${NODE_MAJOR}"
    fi
fi

nvm use default
log_ok "Node.js $(node -v) 就绪"
log_ok "npm $(npm -v) 就绪"

# ---------- 启用 corepack + pnpm ----------
log_info "[4/6] 启用 pnpm..."
if ! corepack enable pnpm 2>/dev/null; then
    log_warn "corepack enable 失败，尝试通过 npm 安装 corepack..."
    npm install -g corepack
    corepack enable pnpm
fi
log_ok "pnpm $(pnpm -v) 就绪"

# ---------- 选择安装方式 ----------
echo ""
echo -e "${CYAN}请选择安装方式${NC}"
echo "  1) 全局安装（推荐，快速，适合日常使用）"
echo "  2) 源码安装（适合开发者或想看代码的同学）"
echo ""
read -rp "请输入 1 或 2（默认 1）: " INSTALL_MODE
INSTALL_MODE=${INSTALL_MODE:-1}

if [ "$INSTALL_MODE" = "2" ]; then
    # ========== 源码安装 ==========
    log_info "[5/6] 从源码安装 OpenClaw..."

    # 默认装到 /mnt/d，D 盘不存在则装到 home 目录
    if [ -d "/mnt/d" ]; then
        INSTALL_DIR="/mnt/d"
    else
        INSTALL_DIR="$HOME"
    fi

    cd "$INSTALL_DIR"

    if [ -d "openclaw" ]; then
        log_warn "openclaw 目录已存在，执行 git pull 更新..."
        cd openclaw
        git pull --ff-only || {
            log_warn "git pull 失败（可能有本地修改），跳过更新"
        }
    else
        log_info "正在克隆 OpenClaw 仓库（可能需要较长时间）..."
        git clone https://github.com/openclaw/openclaw.git
        cd openclaw
    fi

    log_info "正在安装依赖（可能需要较长时间，中途卡住不要关）..."
    pnpm install

    log_info "正在构建 UI..."
    pnpm ui:build

    log_info "正在构建项目..."
    pnpm build

    log_ok "源码构建完成"
    log_info "当前目录为 $(pwd)"
    log_info "源码安装模式下，请使用 pnpm openclaw 来调用命令"

    # ---------- 启动 onboard ----------
    log_info "[6/6] 启动 OpenClaw onboard 向导..."
    echo ""
    echo -e "${CYAN}接下来进入交互式配置界面${NC}"
    echo -e "${CYAN}按提示选择 LLM、配置 API Key、设置消息渠道${NC}"
    echo ""
    read -rp "是否现在启动 onboard 向导？(y/n，默认 y): " START_ONBOARD
    START_ONBOARD=${START_ONBOARD:-y}
    if [[ "$START_ONBOARD" == "y" || "$START_ONBOARD" == "Y" ]]; then
        pnpm openclaw onboard --install-daemon
    else
        echo ""
        log_info "你可以稍后手动执行以下命令启动 onboard"
        echo "  cd $(pwd) && pnpm openclaw onboard --install-daemon"
    fi

else
    # ========== 全局安装 ==========
    log_info "[5/6] 全局安装 OpenClaw..."

    # 设置 SHARP 环境变量避免编译问题
    export SHARP_IGNORE_GLOBAL_LIBVIPS=1

    npm install -g openclaw@latest

    # pnpm 全局安装需要 approve-builds
    log_info "审批构建脚本..."
    pnpm approve-builds -g 2>/dev/null || true

    # 验证 openclaw 是否在 PATH 中
    if command -v openclaw &>/dev/null; then
        log_ok "OpenClaw $(openclaw --version 2>/dev/null || echo '') 就绪"
    else
        log_warn "openclaw 未在 PATH 中检测到"
        log_warn "正在将 npm 全局 bin 目录加入 PATH..."
        NPM_GLOBAL_BIN="$(npm prefix -g)/bin"
        echo "export PATH=\"${NPM_GLOBAL_BIN}:\$PATH\"" >> ~/.bashrc
        export PATH="${NPM_GLOBAL_BIN}:$PATH"
        if command -v openclaw &>/dev/null; then
            log_ok "OpenClaw $(openclaw --version 2>/dev/null || echo '') 就绪（PATH 已修复）"
        else
            log_err "仍然无法找到 openclaw 命令"
            log_err "请手动将以下路径加入 PATH 后重试"
            echo "  ${NPM_GLOBAL_BIN}"
            exit 1
        fi
    fi

    # ---------- 启动 onboard ----------
    log_info "[6/6] 启动 OpenClaw onboard 向导..."
    echo ""
    echo -e "${CYAN}接下来进入交互式配置界面${NC}"
    echo -e "${CYAN}按提示选择 LLM、配置 API Key、设置消息渠道${NC}"
    echo ""
    read -rp "是否现在启动 onboard 向导？(y/n，默认 y): " START_ONBOARD
    START_ONBOARD=${START_ONBOARD:-y}
    if [[ "$START_ONBOARD" == "y" || "$START_ONBOARD" == "Y" ]]; then
        openclaw onboard --install-daemon
    else
        echo ""
        log_info "你可以稍后手动执行以下命令启动 onboard"
        echo "  openclaw onboard --install-daemon"
    fi
fi

echo ""
echo -e "${GREEN}========================================"
echo " 安装完成！"
echo "========================================"
echo ""
echo " 常用命令"
if [ "$INSTALL_MODE" = "2" ]; then
    echo "   cd $(pwd)"
    echo "   pnpm openclaw gateway status    查看网关状态"
    echo "   pnpm openclaw dashboard         打开控制面板"
    echo "   pnpm openclaw tui               终端交互界面"
    echo "   pnpm openclaw doctor            健康检查"
else
    echo "   openclaw gateway status    查看网关状态"
    echo "   openclaw dashboard         打开控制面板"
    echo "   openclaw tui               终端交互界面"
    echo "   openclaw doctor            健康检查"
    echo "   openclaw logs --follow     实时日志"
fi
echo ""
echo " 安全提醒"
echo "   不要以 root 用户运行 OpenClaw"
echo "   不要将 Gateway 直接暴露到公网"
echo "   谨慎安装第三方 Skills，先审查源码"
echo -e "========================================${NC}"
echo ""