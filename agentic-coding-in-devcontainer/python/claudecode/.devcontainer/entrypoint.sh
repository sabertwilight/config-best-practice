#!/bin/bash
# .devcontainer/entrypoint.sh
# DevContainer 统一初始化脚本
# 这是唯一负责 home 目录初始化的地方

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

# ========== 1. 修复 home 目录权限（核心）==========
fix_home_permissions() {
    log_info "检查 /home/vscode 权限..."
    
    # 获取当前属主
    local current_owner
    current_owner=$(stat -c '%U:%G' /home/vscode 2>/dev/null || stat -f '%Su:%Sg' /home/vscode 2>/dev/null)
    
    log_debug "当前权限: $current_owner"
    
    if [ "$current_owner" != "vscode:vscode" ]; then
        log_warn "权限不正确 ($current_owner)，正在修复..."
        
        # 使用 sudo 修复（容器内 vscode 用户有 NOPASSWD sudo 权限）
        sudo chown -R vscode:vscode /home/vscode
        log_info "✓ 权限修复完成"
    else
        log_info "✓ 权限正确"
    fi
}

# ========== 2. 创建目录结构（唯一位置）==========
create_directory_structure() {
    log_info "创建目录结构..."
    
    # Claude 相关目录
    mkdir -p ~/.claude/{settings,agents,commands,hooks,plugins,projects,sessions}
    
    # 其他常用目录
    mkdir -p ~/.local/bin
    mkdir -p ~/.cache
    mkdir -p ~/.config
    
    log_info "✓ 目录结构创建完成"
}

# ========== 3. 初始化 Claude 配置 ==========
init_claude_config() {
    log_info "初始化 Claude 配置..."
    
    local container_settings="/etc/claude/container-settings.json"
    local user_settings="$HOME/.claude/settings.json"
    
    # 如果用户配置不存在，从容器配置复制
    if [ ! -f "$user_settings" ] && [ -f "$container_settings" ]; then
        cp "$container_settings" "$user_settings"
        log_info "✓ 已创建 settings.json"
    elif [ -f "$user_settings" ]; then
        log_info "✓ settings.json 已存在，保留用户配置"
    else
        log_warn "未找到配置模板，跳过"
    fi
}

# ========== 4. 检查环境依赖 ==========
check_dependencies() {
    log_info "检查环境依赖..."
    
    local all_ok=true
    
    # 检查 Claude Code
    if command -v claude &>/dev/null; then
        local claude_version
        claude_version=$(claude --version 2>&1 | head -1 || echo "unknown")
        log_info "✓ Claude Code: $claude_version"
    else
        log_error "✗ Claude Code 未安装"
        all_ok=false
    fi
    
    # 检查 Python
    if command -v python &>/dev/null; then
        log_info "✓ Python: $(python --version | awk '{print $2}')"
    else
        log_error "✗ Python 未安装"
        all_ok=false
    fi
    
    # 检查 Node.js
    if command -v node &>/dev/null; then
        log_info "✓ Node.js: $(node --version)"
    else
        log_warn "⚠ Node.js 未安装（可选）"
    fi
    
    if [ "$all_ok" = true ]; then
        log_info "✓ 环境检查通过"
    else
        log_error "环境检查失败"
        return 1
    fi
}

# ========== 5. 显示环境摘要 ==========
show_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              DevContainer 初始化完成                       ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  用户: $(id -un):$(id -gn)"
    echo "║  Home: $HOME"
    echo "║  工作区: $(pwd)"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  Claude 配置:"
    ls -la ~/.claude/ 2>/dev/null | tail -n +2 | while read -r line; do
        echo "║    $line"
    done
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# ========== 主流程 ==========
main() {
    echo ""
    echo "=========================================="
    echo "  DevContainer 初始化开始"
    echo "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo ""
    
    # 1. 修复权限（必须最先执行）
    fix_home_permissions
    
    # 2. 创建目录结构
    create_directory_structure
    
    # 3. 初始化配置
    # init_claude_config
    
    # 4. 检查依赖
    check_dependencies
    
    # 5. 显示摘要
    show_summary
    
    log_info "初始化完成！"
    
    # 执行传入的命令
    if [ $# -gt 0 ]; then
        log_info "执行命令: $*"
        exec "$@"
    else
        log_info "容器已就绪，等待连接..."
        exec sleep infinity
    fi
}

# 运行主流程
main "$@"
