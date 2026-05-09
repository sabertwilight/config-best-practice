# ccpydev

Claude Code Python Development Template

## 开发环境

使用 uv 管理依赖：

```bash
# 安装依赖
uv sync --extra dev

# 运行应用
uv run python app.py

# 运行测试
uv run pytest

# 代码检查
uv run black . && ruff check . && mypy .
```

## 项目结构

```
.
├── pyproject.toml      # 项目配置和依赖
├── uv.lock            # 锁定依赖版本
├── app.py             # Flask 应用入口
├── README.md          # 本文件
└── .devcontainer/     # 开发容器配置
    ├── devcontainer.json
    ├── Dockerfile
    └── post-create.sh
```
