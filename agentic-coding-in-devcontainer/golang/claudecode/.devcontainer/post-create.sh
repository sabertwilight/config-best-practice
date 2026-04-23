#!/bin/bash
set -e

# 修复volume挂载root的问题
sudo chown -R vscode:vscode /home/vscode

cd /workspace && go mod download || true

# claude plugins
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin marketplace add jarrodwatts/claude-hud
claude plugin install claude-hud

echo '环境验证:' && go version && claude --version
echo "Dev container setup complete!"

