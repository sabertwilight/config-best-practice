FROM swr.cn-east-3.myhuaweicloud.com/vsatlib/python:3.12

# 装系统依赖 + vscode 用户
RUN sed -i '/bullseye-backports/s/^/#/' /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    sudo git curl bash-completion ca-certificates xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

ENV HOME=/home/vscode
ENV UV_PYTHON=/opt/bitnami/python/bin/python3.12
ENV PATH="/usr/local/bin:${PATH}"

# 安装 OpenCode/OMO (Node.js)
RUN curl -fsSL https://opencode.ai/install | bash
RUN mkdir -p /home/vscode/.config/opencode \
    /home/vscode/.local/share/opencode \
    && chown -R vscode:vscode /home/vscode/.config \
    /home/vscode/.local

USER vscode
WORKDIR /workspace
