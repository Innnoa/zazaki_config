# Portable AI Runtime — 可移植 AI 治理运行时

一套工具无关的 AI 行为治理规则，适配 OpenCode、Codex CLI、Cursor、Claude Code、GitHub Copilot。

## 快速开始

```bash
git clone git@github.com:Innnoa/zazaki_config.git
cd zazaki_config/portable_ai_runtime

# 安装到目标工具
./install.sh opencode install      # OpenCode CLI
./install.sh codex    install      # Codex CLI
./install.sh cursor   install ~/my-project    # Cursor（项目级）
./install.sh claude   install ~/my-project    # Claude Code（项目级）
./install.sh copilot  install ~/my-project    # GitHub Copilot（项目级）
```

## 目录结构

```
portable_ai_runtime/
├── AGENTS.md                  # 通用治理入口
├── rules/ai/                  # 核心路由规则（7 文件）
├── workflows/ai/              # 执行工作流（5 文件）
├── references/ai/             # 参考文档（8 文件）
├── skills/                    # 共享技能（22 个）
├── scripts/                   # 治理验证脚本
├── templates/                 # 状态文件模板
│
├── opencode/                  # OpenCode 适配器
│   ├── opencode.template.jsonc
│   ├── plugins/ agents/ commands/ mcp/
│   └── README.md
│
├── adapters/
│   ├── codex/                 # Codex CLI 适配器
│   ├── cursor/                # Cursor 适配器 (.cursorrules)
│   ├── claude-code/           # Claude Code 适配器 (CLAUDE.md)
│   └── copilot/               # GitHub Copilot 适配器
│
├── install.sh                 # 一键安装脚本
└── README.md
```

## 核心能力

- **任务路由**：根据任务类型自动选择 workflow（修 bug / 新功能 / 审查 / vibe）
- **AAR 闭环**：任务完成后强制四问检查，积累可复用经验
- **会话管理**：token 预算控制，长会话自动预警
- **验证链**：smoke check → trigger check → route refs → token budgets → regression test
- **多工具适配**：一套核心规则，通过轻量 adapter 接入不同 AI 工具

## 验证

```bash
./scripts/regression-test.sh   # 运行完整验证链
```

## 定制

安装后编辑对应工具的配置文件：
- OpenCode: `~/.config/opencode/opencode.json`（替换 API key 和 MCP 路径）
- Codex: `~/.codex/config.toml`
- Cursor/Claude/Copilot: 直接编辑项目目录下的入口文件
