# ==========================================
# Claude Code 二进制分发镜像（基于 bitnami/minideb）
# 仅用于 COPY --from，不运行任何服务
# ==========================================
FROM swr.cn-east-3.myhuaweicloud.com/vsatlib/debian:12 AS claude-code

ARG CLAUDE_VERSION=2.1.169
ARG TARGETARCH
ARG CLAUDE_SHA256_X64=""
ARG CLAUDE_SHA256_ARM64=""

# 安装必要工具（bitnami/minideb 使用 install_packages）
RUN install_packages ca-certificates curl file tar

# 下载、解压并校验对应架构的二进制
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) CLAUDE_ARCH="x64" ;; \
        arm64) CLAUDE_ARCH="arm64" ;; \
        *) echo "ERROR: Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    \
    DOWNLOAD_URL="https://github.com/anthropics/claude-code/releases/download/v${CLAUDE_VERSION}/claude-linux-${CLAUDE_ARCH}.tar.gz"; \
    echo ">>> Downloading Claude Code ${CLAUDE_VERSION} (${CLAUDE_ARCH})"; \
    \
    # 下载 tar.gz 到临时位置
    curl -fsSL --retry 3 --connect-timeout 15 --max-time 180 \
        -o /tmp/claude.tar.gz \
        "${DOWNLOAD_URL}"; \
    \
    # 如果提供了 SHA256，则强制校验压缩包完整性
    if [ -n "${CLAUDE_SHA256_X64}" ] && [ "${CLAUDE_ARCH}" = "x64" ]; then \
        echo "${CLAUDE_SHA256_X64}  /tmp/claude.tar.gz" | sha256sum -c -; \
    fi; \
    if [ -n "${CLAUDE_SHA256_ARM64}" ] && [ "${CLAUDE_ARCH}" = "arm64" ]; then \
        echo "${CLAUDE_SHA256_ARM64}  /tmp/claude.tar.gz" | sha256sum -c -; \
    fi; \
    \
    # 解压到 /usr/local/bin
    tar -xzf /tmp/claude.tar.gz -C /usr/local/bin; \
    chmod +x /usr/local/bin/claude; \
    \
    # 清理临时文件
    rm -rf /tmp/claude.tar.gz; \
    \
    # 关键防线：验证是 ELF 可执行文件，不是 HTML 拦截页
    file /usr/local/bin/claude | grep -q "ELF.*executable" || { \
        echo "FATAL: Extracted file is not a valid binary. First 5 lines:"; \
        head -n 5 /usr/local/bin/claude; \
        exit 1; \
    }; \
    \
    # 最终验证：二进制能正常输出版本
    /usr/local/bin/claude --version
