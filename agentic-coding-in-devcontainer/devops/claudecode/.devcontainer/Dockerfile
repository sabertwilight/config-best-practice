FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# 基础工具
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        ansible-core \
        shellcheck \
        curl \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# 安装 shfmt（ShellFormat 扩展依赖）
RUN curl -sS https://webi.sh/shfmt | sh \
    && mv /root/.local/bin/shfmt /usr/local/bin/shfmt || true

# 安装 ansible-lint
RUN pip3 install --user ansible-lint

# 切回非 root（base 镜像已创建 vscode 用户）
USER vscode
