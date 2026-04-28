FROM m.daocloud.io/docker.io/library/python:3.12-bullseye

ARG HTTP_PROXY
ARG HTTPS_PROXY
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}

# 装系统依赖 + vscode 用户
RUN sed -i '/bullseye-backports/s/^/#/' /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    sudo git curl bash-completion ca-certificates xz-utils ripgrep nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

# 把 uv 装进镜像（官方静态链接，无需 cargo）
COPY --from=m.daocloud.io/ghcr.io/astral-sh/uv:0.11 /uv /usr/local/bin/uv
ENV UV_PYTHON=/usr/local/bin/python
ENV HOME=/home/vscode

# ========== 安装 Claude Code ==========
RUN curl -fsSL https://claude.ai/install.sh | bash -s 2.1.118
RUN /home/vscode/.local/bin/claude --version

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
