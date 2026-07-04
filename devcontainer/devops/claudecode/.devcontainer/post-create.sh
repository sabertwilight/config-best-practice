#!/bin/bash
set -e

# 修复 volume 挂载 root 的问题
sudo chown -R vscode:vscode /home/vscode/.claude
# 注入 llm-provider 环境变量
echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc

# === devops 专属：工具版本自检 ===
echo "==============================="
echo "DevOps tools verification"
echo "==============================="
ansible --version | head -1 || true
terraform version | head -1 || true
kubectl version --client --short 2>/dev/null || kubectl version --client | head -1 || true
helm version --short 2>/dev/null || helm version | head -1 || true
gh --version | head -1 || true
echo "==============================="

# claude plugins（所有语言一致）
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin marketplace add jarrodwatts/claude-hud
claude plugin install claude-hud
claude plugin marketplace add forrestchang/andrej-karpathy-skills
claude plugin install andrej-karpathy-skills@karpathy-skills

echo "Dev container setup complete!"
