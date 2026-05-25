# Portable AI Runtime Pack

可移植 AI runtime 配置包，覆盖 OpenCode (`~/.config/opencode/`) 与 Codex CLI (`~/.codex/`) 的治理规则、技能、模板与主配置骨架。

## 目录说明

- `portable_dotcodex/`：runtime pack 主体。
- `portable_dotcodex/opencode.template.jsonc`：脱敏后的 OpenCode 主配置模板，需手动补 API key 与本机路径。
- `portable_dotcodex/config.template.toml`：脱敏后的 Codex `config.toml` 模板。
- `portable_dotcodex/agents/`：OpenCode agent 定义（coder, reviewer, vibe-plan 等）。
- `portable_dotcodex/commands/`：OpenCode command 模板。
- `portable_dotcodex/scripts/`：治理验证脚本。
- `portable_dotcodex/skills/`：OpenCode 技能（brainstorming, vibe, writing-plans 等 18 个）。
- `portable_dotcodex/rules/ai/`：正式治理规则（9 个）。
- `portable_dotcodex/workflows/ai/`：任务工作流（8 个）。
- `portable_dotcodex/references/ai/`：参考样本与 trigger 对照（10 个）。
- `portable_dotcodex/state-templates/`：`AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 模板。
- `excluded/`：故意排除的内容说明。
- `install.sh`：可选安装脚本。

## 已包含

- `AGENTS.md`、`opencode.template.jsonc`、`config.template.toml`、`settings.json`
- `agents/`（6 个 agent 定义）、`commands/`（3 个 command 模板）、`scripts/`（3 个治理脚本）
- `skills/`（18 个技能：brainstorming, codex-session-audit, context-handoff, dispatching-parallel-agents, executing-plans, finishing-a-development-branch, receiving-code-review, requesting-code-review, session-restart-prompt, subagent-driven-development, systematic-debugging, test-driven-development, using-git-worktrees, using-superpowers, verification-before-completion, vibe, writing-plans, writing-skills）
- `rules/ai/`（9 个）、`workflows/ai/`（8 个）、`references/ai/`（10 个）
- `mcp/profiles/`、`mcp/servers.active.json`
- `prompts/security_mode.md`、`templates/`、`handoff/TEMPLATE.md`
- `state-templates/`、`docs/governance/`、`docs/plans/`、`docs/requirements/`

## 未包含

- 真实 API key、token、密钥和敏感字段
- `node_modules/`、`package.json`、`package-lock.json`
- `provider-secrets.env`
- `.serena/`、`.agents/`、`.codex/`
- 当前机器的 `AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 实时内容
- 当前机器的 `handoff/` 实时内容
- `skills/vibe/bundled/`（28MB 自动下发的子技能，vibe 运行时会自动补齐）
- `skills/vibe/outputs/`（运行时产物）
- Codex 的 `[projects."..."] trust_level` 清单

## 建议用法

1. 把整个 `portable_ai_runtime/` 目录带到新设备。
2. 新环境执行 `./install.sh install [target_dir] [--init-state] [--dry-run]`；已有环境升级执行 `./install.sh update [target_dir] [--dry-run]`。
3. 复制 `opencode.template.jsonc` 为 `opencode.json`，补齐 API key 和本机 MCP 路径。
4. 复制 `config.template.toml` 为 `config.toml`，补齐 Codex token 与本机项目路径。
5. 若要理解治理系统结构，优先阅读 `AGENTS.md`、`rules/ai/`、`workflows/ai/`。

## 更新边界

- `update` 默认不覆盖 `opencode.json`、`config.toml`
- `update` 默认不覆盖 live `AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 与 `handoff/`
- `skills/vibe/bundled/` 不在包内，vibe 运行时会自行补齐
