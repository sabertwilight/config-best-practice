# ccdevopsdev DevContainer

基于 `mcr.microsoft.com/devcontainers/base:ubuntu-22.04` + Claude Code 的 DevOps 工具链 devcontainer。

## 工具链

通过 [`devcontainers/features`](https://github.com/devcontainers/features) 安装：

- docker-in-docker
- kubectl + helm + minikube
- terraform
- github-cli

通过 apt/pip 安装：

- ansible-core + ansible-lint
- shellcheck + shfmt

通过 Claude Code 集成：

- claude 二进制（多阶段从 `vsatlib/claudecode:${CC_VERSION}` 提取）
- 三个 plugins：superpowers、claude-hud、andrej-karpathy-skills

## 构建镜像

```bash
# CC_VERSION 默认 2.1.139，可通过 --build-arg CC_VERSION 覆盖
export CC_VERSION=2.1.169
docker build --network host --build-arg HTTP_PROXY=http://127.0.0.1:7890 \
    --build-arg HTTPS_PROXY=http://127.0.0.1:7890 --build-arg CC_VERSION \
    -t ccdevopsdevc:${CC_VERSION}-ubuntu22.04 .
```

> 本目录不走 `devcontainer.json: image` 预构建模式（保留 `build.dockerfile`），因为 devops 工具迭代频繁，本地构建更灵活。

## 与规范的差异

| 项 | 规范 | 本目录 |
|---|---|---|
| 基础镜像 | `vsatlib/<lang>:<ver>` | `mcr.microsoft.com/devcontainers/base:ubuntu-22.04` |
| vscode 用户 | 显式创建 | 依赖 base 镜像 |
| 镜像构建方式 | 预构建 + `image` tag 引用 | `build.dockerfile` 本地构建 |
| 工具链 | Dockerfile apt | `devcontainers/features` |

完整规范见 `devcontainer/README.md`。
