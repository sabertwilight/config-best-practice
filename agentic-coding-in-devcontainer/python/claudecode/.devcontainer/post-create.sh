#!/bin/bash
set -e

# 修复volume挂载root的问题
sudo chown -R vscode:vscode /home/vscode

# 初始化 uv 虚拟环境并安装依赖
cd /workspace
[ -d ".venv" ] || uv venv --seed
[ ! -e "pyproject.toml" ] || uv sync

# claude plugins
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin marketplace add jarrodwatts/claude-hud
claude plugin install claude-hud
claude plugin marketplace add forrestchang/andrej-karpathy-skills
claude plugin install andrej-karpathy-skills@karpathy-skills

echo '环境验证:' && python3 -V && claude --version
echo "Dev container setup complete!"


