ARG PYTHON_BASE=swr.cn-east-3.myhuaweicloud.com/vsatlib/python:3.12
ARG UV_VERSION=0.11.10
ARG CC_VERSION=2.1.139

# ====== 阶段 1：提取 uv（单静态二进制） ======
FROM m.daocloud.io/ghcr.io/astral-sh/uv:${UV_VERSION} AS uv_stage

# ====== 阶段 2：提取 Claude Code ======
FROM swr.cn-east-3.myhuaweicloud.com/vsatlib/claudecode:${CC_VERSION} AS claude_stage

# ====== 阶段 3：最终镜像 ======
FROM ${PYTHON_BASE}

ARG CC_VERSION
ARG UV_VERSION
ENV CC_VERSION=${CC_VERSION}
ENV UV_VERSION=${UV_VERSION}

# 系统依赖 + vscode 用户
RUN sed -i '/bullseye-backports/s/^/#/' /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    sudo git curl bash-completion ca-certificates xz-utils ripgrep nodejs vim direnv \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

# 安装 uv
COPY --from=uv_stage /uv /usr/local/bin/uv
ENV UV_PYTHON=/opt/bitnami/python/bin/python3.12
ENV HOME=/home/vscode

# 安装 Claude Code
COPY --from=claude_stage /usr/local/bin/claude /usr/local/bin/claude
ENV PATH="/usr/local/bin:/home/vscode/.local/bin:${PATH}"

# entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER vscode
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
