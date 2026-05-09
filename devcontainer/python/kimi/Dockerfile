FROM swr.cn-east-3.myhuaweicloud.com/vsatlib/python:3.12

# 装系统依赖 + vscode 用户
RUN sed -i '/bullseye-backports/s/^/#/' /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    sudo git curl bash-completion \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 vscode \
    && useradd -u 1000 -g vscode -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode

# 把 uv 装进镜像（官方静态链接，无需 cargo）
COPY --from=m.daocloud.io/ghcr.io/astral-sh/uv:0.9 /uv /usr/local/bin/uv

ENV HOME=/home/vscode
ENV UV_PYTHON=/opt/bitnami/python/bin/python3.12

RUN uv tool install --python 3.12 kimi-cli

USER vscode
WORKDIR /workspace
