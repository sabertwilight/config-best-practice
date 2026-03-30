FROM m.daocloud.io/docker.io/library/python:3.12-bullseye

# 装系统依赖 + vscode 用户
RUN sed -i '/bullseye-backports/s/^/#/' /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    sudo git curl bash-completion ca-certificates xz-utils ripgrep \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

# 把 uv 装进镜像（官方静态链接，无需 cargo）
COPY --from=m.daocloud.io/ghcr.io/astral-sh/uv:0.11 /uv /usr/local/bin/uv
ENV UV_PYTHON=/usr/local/bin/python
ENV HOME=/home/vscode

# ========== 安装 Claude Code ==========
# BuildKit 会自动注入 HTTP_PROXY/HTTPS_PROXY 到 RUN 指令
# 这些变量不会残留到最终镜像 [1][2]
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && /home/vscode/.local/bin/claude --version
# 确保 .local/bin 在 PATH 中
ENV PATH="/usr/local/bin:/home/vscode/.local/bin:${PATH}"

# 预创建 Claude 配置目录
RUN mkdir -p /home/vscode/.claude/agents \
    && mkdir -p /home/vscode/.claude/sessions \
    && chown -R vscode:vscode /home/vscode/.claude \
    && chown -R vscode:vscode /home/vscode/.local \
    && chown -R vscode:vscode /home/vscode/.cache

USER vscode
WORKDIR /workspace
