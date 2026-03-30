FROM m.daocloud.io/docker.io/library/golang:1.25-trixie

# 装系统依赖 + vscode 用户
RUN apt-get update && apt-get install -y \
    sudo git curl bash-completion ca-certificates xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

ENV HOME=/home/vscode
ENV PATH="/usr/local/bin:${PATH}"

# 安装 OpenCode/OMO (Node.js)
RUN curl -fsSL https://opencode.ai/install | bash

# 预创建 opencode 配置目录
RUN mkdir -p /home/vscode/.config/opencode \
    /home/vscode/.local/share/opencode \
    && chown -R vscode:vscode /home/vscode/.config \
    /home/vscode/.local

USER vscode
WORKDIR /workspace
