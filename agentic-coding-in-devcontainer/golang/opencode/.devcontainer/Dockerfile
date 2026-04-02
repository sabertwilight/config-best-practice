FROM m.daocloud.io/docker.io/library/golang:1.25-trixie

# ========== 配置清华 apt 源（DEB822 格式）==========
RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    cat > /etc/apt/sources.list.d/debian.sources << 'EOF'
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/debian/
Suites: trixie trixie-updates trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
# 安全更新源（推荐使用官方源以获得及时更新）
Types: deb
URIs: https://security.debian.org/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

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
