#!/bin/bash
set -e

# 初始化 uv 虚拟环境并安装依赖
cd /workspace
[ -d ".venv" ] || uv venv --seed
[ ! -e "pyproject.toml" ] || uv sync

echo "Dev container setup complete!"
