ARG CC_VERSION=2.1.139

# ====== 阶段 1：提取 Claude Code ======
FROM swr.cn-east-3.myhuaweicloud.com/vsatlib/claudecode:${CC_VERSION} AS claude_stage

# ====== 阶段 2：最终镜像 ======
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG CC_VERSION
ENV CC_VERSION=${CC_VERSION}

# 基础工具（devops 工具链）
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        ansible-core \
        shellcheck \
        bash-completion \
        ca-certificates \
        gnupg \
        lsb-release \
        ripgrep \
        vim \
        direnv \
        nodejs \
        xz-utils \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# 安装 shfmt（ShellFormat 扩展依赖）
RUN curl -sS https://webi.sh/shfmt | sh \
    && mv /root/.local/bin/shfmt /usr/local/bin/shfmt || true

# 安装 ansible-lint
RUN pip3 install --user ansible-lint

ENV HOME=/home/vscode

# 安装 Claude Code
COPY --from=claude_stage /usr/local/bin/claude /usr/local/bin/claude
ENV PATH="/usr/local/bin:/home/vscode/.local/bin:${PATH}"

# 设置 entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 切回非 root（base 镜像已创建 vscode 用户）
USER vscode
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
