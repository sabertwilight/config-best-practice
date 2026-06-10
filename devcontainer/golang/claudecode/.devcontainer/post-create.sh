#!/bin/bash
set -e

# 修复volume挂载root的问题
sudo chown -R vscode:vscode /home/vscode
# 注入llm-provider环境变量
echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc

go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct

# 语言服务器（补全、跳转、重构）
go install golang.org/x/tools/gopls@latest
# 自动导入/删包
go install golang.org/x/tools/cmd/goimports@latest
# 调试器
go install github.com/go-delve/delve/cmd/dlv@latest
# 静态检查
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
cd /workspace && go mod download || true

# claude plugins
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin marketplace add jarrodwatts/claude-hud
claude plugin install claude-hud
claude plugin marketplace add forrestchang/andrej-karpathy-skills
claude plugin install andrej-karpathy-skills@karpathy-skills

echo '环境验证:' && go version && claude --version
echo "Dev container setup complete!"
