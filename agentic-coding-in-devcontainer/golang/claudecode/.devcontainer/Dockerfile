FROM m.daocloud.io/docker.io/library/golang:1.25-trixie

ARG HTTP_PROXY
ARG HTTPS_PROXY
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}

# ========== 配置清华 apt 源（DEB822 格式）==========
COPY debian.sources /etc/apt/sources.list.d/debian.sources

# 装系统依赖 + vscode 用户
RUN apt-get update && apt-get install -y \
    sudo git curl bash-completion ca-certificates xz-utils locales nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

ENV HOME=/home/vscode

# ========== 安装 Claude Code ==========
RUN curl -fsSL https://claude.ai/install.sh | bash -s 2.1.118 \
    && /home/vscode/.local/bin/claude --version

ENV PATH="/usr/local/bin:/home/vscode/.local/bin:${PATH}"

# ========== 复制 entrypoint 脚本 ==========
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 切换用户
USER vscode
WORKDIR /workspace

# 设置 entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
