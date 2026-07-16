# Portable AI Runtime — 可移植 AI 治理运行时

一套工具无关的 AI 行为治理规则，通过轻量 adapter 适配 OpenCode、Codex CLI、Cursor、Claude Code、GitHub Copilot。

## 快速开始

```bash
git clone git@github.com:Innnoa/zazaki_config.git
cd zazaki_config/portable_ai_runtime
./install.sh                          # 交互菜单: 选工具 → 选全局/项目 → 确认
```

**交互流程**：所有五种工具统一走"选工具 → 选范围 → 确认"三步。全局安装用文件复制，项目安装用符号链接（更新仓库即同步所有项目）。

命令行模式（脚本自动化）：

```bash
./install.sh opencode install                  # OpenCode 全局 → ~/.config/opencode/
./install.sh opencode install ~/my-project     # OpenCode 项目 → 指定目录
./install.sh cursor   install ~/my-project     # Cursor 项目 → .cursorrules + 符号链接
./install.sh claude   install ~/.claude        # Claude 全局 → ~/.claude/CLAUDE.md
./install.sh copilot  install ~/my-project     # Copilot 项目 → .github/

./install.sh opencode update                   # 更新已有 OpenCode 安装
./install.sh codex    update                   # 更新已有 Codex 安装
```

所有命令支持 `--dry-run`（预览）和 `--init-state`（初始化状态文件）。

## 目录结构

```
portable_ai_runtime/
├── AGENTS.md                  # 通用治理入口（所有工具共用）
├── rules/ai/                  # 核心路由规则（7 文件）
├── workflows/ai/              # 执行工作流（5 文件）
├── references/ai/             # 参考文档 — 坑点、反模式、触发词
├── skills/                    # 共享技能（22 个，含 vibe 运行时）
├── scripts/                   # 治理验证脚本 + pre-commit hook
├── templates/                 # 状态文件模板（状态文件、协议块、shell）
│
├── opencode/                  # OpenCode 适配器
│   ├── opencode.template.jsonc   # 配置模板（含 agent/command/MCP 定义）
│   ├── plugins/ agents/ commands/ mcp/ prompts/
│   └── README.md
│
├── adapters/                  # 其他工具适配器
│   ├── codex/                    # config.template.toml + settings.json
│   ├── cursor/                   # .cursorrules
│   ├── claude-code/              # CLAUDE.md
│   └── copilot/                  # copilot-instructions.md
│
├── install.sh                 # 一键安装脚本（5 种工具）
└── README.md
```

## 核心能力

| 能力 | 说明 |
|---|---|
| 任务路由 | 根据任务类型自动选择 workflow — 修 bug / 新功能 / 审查 / vibe |
| AAR 闭环 | 任务完成后强制四问检查，积累可复用经验，自动分类入 inbox |
| 会话管理 | token 预算控制 (100K 预警 / 150K 强提醒)，长会话自动提示开新会话 |
| 治理验证链 | `./scripts/regression-test.sh` 一键运行 5 项全量检查 |
| 提交门禁 | pre-commit hook + repo-audit，拦截 AI 产物和密钥 |

## 验证

```bash
./scripts/regression-test.sh       # 5 项全量检查（smoke / trigger / routes / tokens / gitignore）
./scripts/ai-governance-smoke-check.sh  # 单独运行入门口检查
```

## 配置 API Key

所有 `{env:VAR_NAME}` 占位符通过环境变量注入，不在配置文件中存裸密钥。

### 方式一：手动 export

```bash
# 在 ~/.zshrc 或 ~/.bashrc 中
export OPENAI_API_KEY="sk-xxx"
export DEEPSEEK_API_KEY="sk-xxx"
export BRAVE_API_KEY="xxx"
export GITHUB_TOKEN="xxx"
```

### 方式二：provider-secrets.env（推荐）

创建 `~/.config/opencode/provider-secrets.env`（不会被 git 追踪）：

```bash
OPENAI_API_KEY="sk-xxx"
DEEPSEEK_API_KEY="sk-xxx"
BRAVE_API_KEY="xxx"
GITHUB_TOKEN="ghp_xxx"
```

启动时 source：

```bash
source ~/.config/opencode/provider-secrets.env && opencode
```

或加到 `~/.zshrc`：

```bash
alias op="source ~/.config/opencode/provider-secrets.env && opencode"
```

## 定制

| 工具 | 配置文件 | 修改内容 |
|---|---|---|
| OpenCode | `~/.config/opencode/opencode.json` | 替换 MCP 路径、检查 provider baseURL |
| Codex | `~/.codex/config.toml` | 填入 token 和 provider 配置 |
| Cursor | 项目目录 `.cursorrules` | 直接编辑入口文件 |
| Claude Code | 项目目录 `CLAUDE.md` | 直接编辑入口文件 |
| Copilot | 项目目录 `.github/copilot-instructions.md` | 提交到 Git 仓库后生效

## 安装原理

```
所有工具 → 选工具 → 选范围 → 确认

全局安装: 仓库 → 文件复制 → 配置目录（所有项目生效，独立运行）
项目安装: 仓库 → 符号链接 → 项目目录（仅该项目生效，git pull 即同步）
```
