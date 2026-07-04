# DevContainer 模板规范

本目录提供基于 **Claude Code** 的多语言 devcontainer 模板。每个语言目录（`golang/`、`python/`、`nodejs/`、`devops/` 等）下挂载若干 agent 子目录（目前只有 `claudecode/`），每个 agent 子目录都是一个独立可用的 devcontainer。

> **混合实现例外**：`devops/claudecode/` 因为工具链特性保留 `build.dockerfile` + `devcontainers/features` 路线，但已补齐 Claude Code 集成（5 条 mounts / 5 函数 entrypoint / 3 个 plugins）。详见"当前覆盖"表的 DevOps 行。

---

## 目录结构

每个 `<lang>/<agent>/` 必须长这样：

```
<lang>/<agent>/
├── .devcontainer/
│   ├── devcontainer.json     # 容器元配置（挂载、网络、VS Code 扩展）
│   ├── Dockerfile            # 镜像构建（多阶段，最终镜像基于语言官方镜像）
│   ├── entrypoint.sh         # 容器启动入口（修复权限、建目录、初始化 settings、检查依赖）
│   ├── post-create.sh        # 创建后钩子（语言工具链安装、claude plugins）
│   └── README.md             # 镜像构建命令
└── <语言自身项目文件>
```

5 份文件里，**`devcontainer.json` / `Dockerfile` / `entrypoint.sh` / `post-create.sh` / 子目录 README** 的骨架已经统一，只有"语言专属"那一段需要按语言改。

---

## 命名约定

| 角色 | 格式 | 示例 |
|---|---|---|
| devcontainer `name` | `cc<lang>dev` | `ccgodev`、`ccpydev`、`ccnodev` |
| image tag | `cc<lang>devc:<cc_version>-<lang_version>-<os>` | `ccnodevc:2.1.169-18-debian11` |
| Claude 数据卷 | `cc<lang>dev-cc` | `ccgodev-cc` |

---

## 公共模板

### 1. `devcontainer.json`

把下面这份骨架拷贝过去，把 `<…>` 占位符替换成实际值即可：

```jsonc
{
    "name": "cc<LANG>dev",
    "image": "cc<LANG>devc:<CC_VERSION>-<LANG_VERSION>-<OS>",
    "runArgs": [
        "--add-host=host.docker.internal:host-gateway",
        "--network",
        "app32"
    ],
    "containerEnv": {
        "HTTP_PROXY": "http://host.docker.internal:7890",
        "HTTPS_PROXY": "http://host.docker.internal:7890",
        "NO_PROXY": "localhost,127.0.0.1"
    },
    "customizations": {
        "vscode": {
            "settings": {
                // === 语言专属 VS Code 设置 ===
            },
            "extensions": [
                // === 语言专属扩展列表 ===
                "anthropic.claude-code"   // 所有语言统一追加在末尾
            ]
        }
    },
    "mounts": [
        "source=${localWorkspaceFolder:HOME}/.devcontainer,target=/workspace/.devcontainer,type=bind,consistency=cached",
        "source=cc<LANG>dev-cc,target=/home/vscode/.claude,type=volume",
        "source=${localEnv:HOME}/.claude/settings,target=/home/vscode/.claude/settings,type=bind,consistency=cached",
        "source=${localEnv:HOME}/.claude/plugins/claude-hud/config.json,target=/home/vscode/.claude/plugins/claude-hud/config.json,type=bind,consistency=cached",
        "source=${localEnv:HOME}/.config/llm-providers,target=/home/vscode/.config/llm-providers,type=bind,consistency=cached"
    ],
    "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",
    "workspaceFolder": "/workspace",
    "remoteUser": "vscode",
    "postCreateCommand": "bash .devcontainer/post-create.sh"
}
```

固定不变的部分：
- `runArgs` / `containerEnv` / `workspaceMount` / `workspaceFolder` / `remoteUser` / `postCreateCommand`
- 5 条 `mounts`（按上面顺序）
- `extensions` 列表末尾固定追加 `"anthropic.claude-code"`

需要按语言改的部分：
- `name` / `image` / mount 里的 volume 名（替换 `<LANG>`）
- `customizations.vscode.settings`：语言专属设置（formatter、lint、test 等）
- `customizations.vscode.extensions`：语言专属扩展（保留末尾的 `anthropic.claude-code`）

---

### 2. `Dockerfile`

多阶段构建：第一阶段只用来剥出 `claude` 二进制，第二阶段基于语言官方镜像叠加系统依赖和入口脚本。

```dockerfile
ARG <LANG>_BASE=swr.cn-east-3.myhuaweicloud.com/vsatlib/<lang>:<LANG_VERSION>
ARG CC_VERSION=2.1.139

# ====== 阶段 1：提取 Claude Code ======
FROM swr.cn-east-3.myhuaweicloud.com/vsatlib/claudecode:${CC_VERSION} AS claude_stage

# ====== 阶段 2：最终镜像 ======
FROM ${<LANG>_BASE}

ARG CC_VERSION
ENV CC_VERSION=${CC_VERSION}

# 系统依赖 + vscode 用户
RUN apt-get update && apt-get install -y \
    sudo git curl bash-completion ca-certificates xz-utils ripgrep nodejs vim direnv \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

ENV HOME=/home/vscode

# 安装 Claude Code
COPY --from=claude_stage /usr/local/bin/claude /usr/local/bin/claude
ENV PATH="/usr/local/bin:/home/vscode/.local/bin:${PATH}"

# 设置 entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER vscode
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
```

固定不变的部分：apt 包列表（含 `nodejs`——多数语言镜像里没有 Claude Code 需要）、vscode 用户创建块、Claude Code 二进制拷贝、`USER vscode` / `ENTRYPOINT` / `CMD`。

需要按语言改的部分：
- `<LANG>_BASE`：基础镜像 tag（如 `vsatlib/python:3.12`、`vsatlib/node:18`）
- 若语言需要前置工具链（如 Python 的 `uv`），可在 `claude_stage` 之前插入更多 `FROM … AS <name>_stage`

---

### 3. `entrypoint.sh`

**所有语言共用同一份**（`check_dependencies` 里的语言检查项除外）。直接复用下面完整内容：

```bash
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

    local current_owner
    current_owner=$(stat -c '%U:%G' /home/vscode 2>/dev/null || stat -f '%Su:%Sg' /home/vscode 2>/dev/null)

    log_debug "当前权限: $current_owner"

    if [ "$current_owner" != "vscode:vscode" ]; then
        log_warn "权限不正确 ($current_owner)，正在修复..."

        sudo chown -R vscode:vscode /home/vscode
        log_info "✓ 权限修复完成"
    else
        log_info "✓ 权限正确"
    fi
}

# ========== 2. 创建目录结构（唯一位置）==========
create_directory_structure() {
    log_info "创建目录结构..."

    mkdir -p ~/.claude/{settings,agents,commands,hooks,plugins,projects,sessions}
    mkdir -p ~/.local/bin
    mkdir -p ~/.cache
    mkdir -p ~/.config

    log_info "✓ 目录结构创建完成"
}

# ========== 3. 初始化 Claude 配置 ==========
init_claude_config() {
    log_info "初始化 Claude 配置..."

    local user_settings="$HOME/.claude/settings.json"
    local template_settings
    template_settings=$(ls -t $HOME/.claude/settings/*.json 2>/dev/null | head -1 || true)

    if [ -f "$user_settings" ]; then
        log_info "✓ settings.json 已存在，保留用户配置"
        return 0
    fi

    if [ -n "$template_settings" ] && [ -f "$template_settings" ]; then
        cp "$template_settings" "$user_settings"
        log_info "✓ 已从模板创建 settings.json（来源：$template_settings）"
    else
        log_warn "未找到 settings 模板，跳过"
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

    # === 以下替换为语言专属检查 ===
    # 示例（Go）：
    # if command -v go &>/dev/null; then
    #     log_info "✓ Go: $(go version | awk '{print $3}')"
    # else
    #     log_error "✗ Go 未安装"
    #     all_ok=false
    # fi
    # === 语言专属结束 ===

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
    init_claude_config

    # 4. 检查依赖
    check_dependencies

    # 5. 显示摘要
    show_summary

    log_info "初始化完成！"

    if [ $# -gt 0 ]; then
        log_info "执行命令: $*"
        exec "$@"
    else
        log_info "容器已就绪，等待连接..."
        exec sleep infinity
    fi
}

main "$@"
```

需要按语言改的部分：
- 仅 `check_dependencies` 函数中的"语言专属检查"段。主语言（如 Go / Python / Node）必须存在，缺失时标 `error`；次要工具（如 `nodejs` 在 Go/Python 里）可标 `warn` 设为可选。

---

### 4. `post-create.sh`

骨架（公共部分完全一致，只有中间"工具链安装"段按语言改）：

```bash
#!/bin/bash
set -e

# 修复 volume 挂载 root 的问题
sudo chown -R vscode:vscode /home/vscode/.claude
# 注入 llm-provider 环境变量
echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc

# === 以下为语言专属：初始化语言工具链 ===
# 示例（Go）：
#   go env -w GO111MODULE=on
#   go env -w GOPROXY=https://goproxy.cn,direct
#   go install golang.org/x/tools/gopls@latest
#   ...
#   cd /workspace && go mod download || true
# === 语言专属结束 ===

# claude plugins（所有语言一致）
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin marketplace add jarrodwatts/claude-hud
claude plugin install claude-hud
claude plugin marketplace add forrestchang/andrej-karpathy-skills
claude plugin install andrej-karpathy-skills@karpathy-skills

echo "Dev container setup complete!"
```

公共部分（保持原样）：权限修复 + direnv hook + 三个 claude plugins 安装。

语言专属部分（替换 `=== 语言专属 ===` 之间的内容）：
- 包管理器配置（如 Go 的 `GOPROXY`、Node 的 `npm config set registry`）
- 语言服务器 / linter / formatter 安装
- 项目依赖安装（如 Python 的 `uv sync`、Node 的 `npm install`）

---

### 5. `.devcontainer/README.md`

```markdown
# Base image build cli
\`\`\`bash
# CC_VERSION 默认 2.1.139，可通过 --build-arg CC_VERSION 覆盖（从环境变量读取）
export CC_VERSION=2.1.169
docker build --network host --no-cache --build-arg HTTP_PROXY=http://127.0.0.1:7890 --build-arg HTTPS_PROXY=http://127.0.0.1:7890 --build-arg CC_VERSION -t cc<LANG>devc:${CC_VERSION}-<LANG_VERSION>-<OS> .
\`\`\`
```

---

## 版本策略

三处涉及 Claude Code 版本号，故意保持差异：

| 文件 | 默认值 | 用途 |
|---|---|---|
| `Dockerfile` `ARG CC_VERSION` | `2.1.139` | 镜像构建默认值（CI / 无人值守时使用） |
| `README.md` `export CC_VERSION` | `2.1.169` | 提示用户可通过环境变量覆盖默认 |
| `devcontainer.json` `image` | 跟实际镜像 | 引用已经构建好的镜像 tag |

设计意图：Dockerfile 给"懒人默认"，README 给"想用最新版"的用户一个 hint——只要 `export CC_VERSION=…` 就能覆盖。`devcontainer.json` 的 image tag 必须和实际构建出的镜像一致。

---

## 各语言定制点速查

| 文件 | 公共不变 | 需要改 |
|---|---|---|
| `devcontainer.json` | `runArgs` / `containerEnv` / `workspaceMount` / `workspaceFolder` / `remoteUser: vscode` / `postCreateCommand` / 5 条 `mounts` | `name` / `image` / volume 名 / `vscode.settings` / `vscode.extensions` |
| `Dockerfile` | apt 包列表 / vscode 用户创建块 / Claude Code 二进制拷贝 / `USER vscode` / `ENTRYPOINT` / `CMD` | `<LANG>_BASE` 基础镜像 tag / 是否需要多阶段前置 |
| `entrypoint.sh` | 5 个函数全部 + main 主流程 | `check_dependencies` 函数中的语言检查项 |
| `post-create.sh` | 权限修复 / direnv hook / 3 个 claude plugins 安装 | 中间"工具链安装"段 |
| `README.md` | 命令模板 | `<LANG>` / `<LANG_VERSION>` / `<OS>` 三个占位符 |

---

## 新增一个语言 devcontainer 的 Checklist

1. **创建目录骨架**
   ```bash
   mkdir -p <lang>/claudecode/.devcontainer
   ```

2. **按上面的公共模板拷贝 5 份文件**，替换 `<LANG>` 等占位符

3. **填语言专属部分**
   - `devcontainer.json`：`vscode.settings` / `vscode.extensions`（保留末尾 `anthropic.claude-code`）
   - `Dockerfile`：选择合适的 `<LANG>_BASE`，若需要 `uv`/`pnpm` 之类的前置工具则加多阶段
   - `entrypoint.sh`：`check_dependencies` 函数里加语言主程序的存在性检查
   - `post-create.sh`：填入语言工具链安装块

4. **本地语法检查**
   ```bash
   # devcontainer.json
   python3 -m json.tool <lang>/claudecode/.devcontainer/devcontainer.json > /dev/null

   # shell 脚本
   bash -n <lang>/claudecode/.devcontainer/entrypoint.sh
   bash -n <lang>/claudecode/.devcontainer/post-create.sh
   ```

5. **构建镜像并冒烟**
   ```bash
   cd <lang>/claudecode/.devcontainer
   docker build --network host --build-arg HTTP_PROXY=http://127.0.0.1:7890 \
       --build-arg HTTPS_PROXY=http://127.0.0.1:7890 -t cc<LANG>devc:smoke .
   docker run --rm cc<LANG>devc:smoke claude --version
   docker run --rm cc<LANG>devc:smoke <主语言> --version
   ```

6. **可选**：在下面的"当前覆盖"表格里追加新语言一行

---

## 当前覆盖

| 语言 | 目录 | 基础镜像 | 主语言版本 | Claude 版本（README） | 与规范关系 |
|---|---|---|---|---|---|
| Go | `golang/claudecode/` | `vsatlib/golang:1.25` | 1.25 | 2.1.169 | 完全对齐 |
| Python | `python/claudecode/` | `vsatlib/python:3.12` | 3.12 | 2.1.169 | 完全对齐 |
| Node.js | `nodejs/claudecode/` | `vsatlib/node:18` | 18 | 2.1.169 | 完全对齐 |
| DevOps | `devops/claudecode/` | `mcr.microsoft.com/devcontainers/base:ubuntu-22.04` | — | 2.1.169 | **混合（B 方案）**：保留 `build.dockerfile` + `devcontainers/features`，但补齐 Claude Code 集成、5 条 mounts、5 函数 entrypoint、3 个 plugins |

---

## 改动一条规范

这五份文件的"公共不变部分"理论上可以抽到一个共享目录由 Dockerfile `COPY` 引用，但目前接受适度的冗余——每改一处规范要同步四个语言目录。等第五个语言加入时建议先抽共享脚本，避免漂移。
