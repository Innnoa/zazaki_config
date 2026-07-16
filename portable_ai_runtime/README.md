# Portable AI Runtime — 可移植 AI 治理运行时

一套工具无关的 AI 行为治理规则，通过轻量 adapter 适配 OpenCode、Codex CLI、Cursor、Claude Code、GitHub Copilot。

## 快速开始

```bash
git clone git@github.com:Innnoa/zazaki_config.git
cd zazaki_config/portable_ai_runtime
```

### 系统级工具（复制安装）

独立运行环境，复制全套规则到工具配置目录：

```bash
./install.sh opencode install        # → ~/.config/opencode/
./install.sh opencode update         # 更新已有安装
./install.sh codex    install        # → ~/.codex/
```

### 项目级工具（符号链接安装）

只在项目目录放一个入口文件，核心规则通过符号链接引用。更新仓库一次，所有项目自动同步：

```bash
./install.sh cursor  install ~/my-project    # → .cursorrules + 符号链接
./install.sh claude  install ~/my-project    # → CLAUDE.md + 符号链接
./install.sh copilot install ~/my-project    # → .github/copilot-instructions.md + 符号链接
```

所有安装命令均支持 `--dry-run`（预览模式）和 `--init-state`（初始化状态文件）。

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

## 定制

| 工具 | 配置文件 | 修改内容 |
|---|---|---|
| OpenCode | `~/.config/opencode/opencode.json` | 替换 API key (`{env:VAR}`)、MCP 路径 (`YOUR_PATH`) |
| Codex | `~/.codex/config.toml` | 填入 token 和 provider 配置 |
| Cursor | 项目目录 `.cursorrules` | 直接编辑入口文件 |
| Claude Code | 项目目录 `CLAUDE.md` | 直接编辑入口文件 |
| Copilot | 项目目录 `.github/copilot-instructions.md` | 提交到 Git 仓库后生效 |

所有 API key 使用 `{env:VAR_NAME}` 占位符，不在配置文件中存裸密钥。

## 安装原理

```
系统级 (opencode/codex):
  仓库 → 复制 core/ + 工具配置 → ~/.config/opencode/
  工具自行读取其配置目录下的文件。

项目级 (cursor/claude/copilot):
  仓库 → 入口文件复制 + core/ 符号链接 → 项目目录
  工具读取入口文件 → 通过相对路径引用 core/ 规则。
  git pull 仓库 → 所有项目自动获得最新规则。
```
