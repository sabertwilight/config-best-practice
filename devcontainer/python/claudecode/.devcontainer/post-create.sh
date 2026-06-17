#!/bin/bash
set -e

sudo chown -R vscode:vscode /home/vscode/.claude
################################
#
# Infra & tools
#
################################
# 注入llm-provider环境变量
echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc

# claude plugins
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin marketplace add jarrodwatts/claude-hud
claude plugin install claude-hud
claude plugin marketplace add forrestchang/andrej-karpathy-skills
claude plugin install andrej-karpathy-skills@karpathy-skills

echo "==============================="
echo "Infra & tool setup complete!"
echo "==============================="

################################
#
# Project: deps/db migrate
#
################################
# 初始化 uv 虚拟环境并安装依赖
cd /workspace
[ -d ".venv" ] || uv venv --seed
[ ! -e "pyproject.toml" ] || uv sync

echo "==============================="
echo "Project setup complete!"
echo "==============================="
echo "Dev container setup complete!"
