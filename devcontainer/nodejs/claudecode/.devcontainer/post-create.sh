#!/bin/bash
set -e

# 修复volume挂载root的问题
sudo chown -R vscode:vscode /home/vscode/.claude
# 注入llm-provider环境变量
echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc

# 配置 npm 国内镜像源
npm config set registry https://registry.npmmirror.com

# claude plugins
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin marketplace add jarrodwatts/claude-hud
claude plugin install claude-hud
claude plugin marketplace add forrestchang/andrej-karpathy-skills
claude plugin install andrej-karpathy-skills@karpathy-skills

echo '环境验证:' && node --version && npm --version && claude --version
echo "Dev container setup complete!"
