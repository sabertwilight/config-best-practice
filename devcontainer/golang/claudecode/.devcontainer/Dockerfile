ARG GOLANG_BASE=swr.cn-east-3.myhuaweicloud.com/vsatlib/golang:1.25
ARG CC_VERSION=2.1.139

# ====== 阶段 1：提取 Claude Code ======
FROM swr.cn-east-3.myhuaweicloud.com/vsatlib/claudecode:${CC_VERSION} AS claude_stage

# ====== 阶段 2：最终镜像 ======
FROM ${GOLANG_BASE}

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
