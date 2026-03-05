FROM swr.cn-east-3.myhuaweicloud.com/vsatlib/python:3.12

# 装系统依赖 + vscode 用户
RUN sed -i '/bullseye-backports/s/^/#/' /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    sudo git curl bash-completion ca-certificates xz-utils \
    # 方式：像 uv 一样直接解压 Node.js 官方预编译包到 /usr/local
    && curl -fsSL https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz \
       | tar -xJf - -C /usr/local --strip-components=1 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

ENV HOME=/home/vscode
ENV UV_PYTHON=/opt/bitnami/python/bin/python3.12
ENV PATH="/usr/local/bin:${PATH}"

# 安装 Claude Code (Node.js) - 全局安装并修正权限
RUN npm install -g @anthropic-ai/claude-code \
    && chown -R vscode:vscode /usr/local/lib/node_modules \
    && chown vscode:vscode /usr/local/bin/claude

USER vscode
WORKDIR /workspace
