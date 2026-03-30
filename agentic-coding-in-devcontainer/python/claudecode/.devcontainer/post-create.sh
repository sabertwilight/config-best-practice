#!/bin/bash
set -e

# 初始化 uv 虚拟环境并安装依赖
cd /workspace
[ -d ".venv" ] || uv venv --seed
uv sync

echo "Dev container setup complete!"
