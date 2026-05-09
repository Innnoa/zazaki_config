# Portable AI Runtime Pack

这个目录是“可移植版” AI runtime 配置包，用于在别的设备上复用治理规则、模板和主配置骨架。当前内层 runtime pack 目录仍为 `portable_dotcodex/`，默认安装目标仍是 `~/.codex/`。

## 目录说明

- `portable_dotcodex/`：建议同步到新设备 `~/.codex/` 的内容。
- `portable_dotcodex/config.template.toml`：脱敏后的 `config.toml` 模板，需要手动补 token 和本机路径。
- `portable_dotcodex/state-templates/`：`AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 模板。
- `portable_dotcodex/rules/ai/`：正式治理规则。
- `portable_dotcodex/workflows/ai/`：任务工作流与协议。
- `portable_dotcodex/references/ai/`：高价值样本与 trigger 对照。
- `excluded/`：说明哪些当前机器状态被故意排除。
- `install.sh`：可选安装脚本，支持 `install` / `update` 两种模式，并可选从模板初始化状态文件。

## 已包含

- `AGENTS.md`
- `config.template.toml`
- `settings.json`
- `mcp/profiles/`
- `mcp/servers.active.json`
- `prompts/security_mode.md`
- `templates/`
- `handoff/TEMPLATE.md`
- `skills/context-handoff/`
- `state-templates/`
- `rules/ai/`
- `workflows/ai/`
- `references/ai/`
- `docs/governance/`
- `docs/requirements/README.md`
- `docs/plans/README.md`

## 未包含

- 真实 token、密钥和其他敏感字段
- 当前机器的 `[projects."..."] trust_level` 清单
- `tmp/`、`outputs/runtime/vibe-sessions/`
- `.vibeskills/install-ledger.json`、`.vibeskills/mcp-auto-provision.json`
- 当前机器的 `AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 实时内容
- 当前机器的 `handoff/` 实时内容

## 建议用法

1. 把整个 `portable_ai_runtime/` 目录带到新设备。
2. 新环境执行 `./install.sh install [target_dir] [--init-state] [--dry-run]`；已有环境升级执行 `./install.sh update [target_dir] [--dry-run]`。
3. `install` 会复制 runtime pack；`update` 会更新治理/runtime 文件，但默认不覆盖 live state 文件和 `config.toml`。
4. `--dry-run` 只做高层预览，不写文件，也不做逐文件内容 diff。
5. 打开目标目录下的 `config.toml`，补齐 token、provider、项目 trust 和本机路径。
6. 若使用 `--init-state`，脚本会在缺失时从模板初始化 `AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 和 `handoff/TEMPLATE.md`。
7. 若要理解治理系统结构，优先阅读 `portable_dotcodex/AGENTS.md`、`rules/ai/`、`workflows/ai/`、`references/ai/`。
8. 若新设备也要用 `shrimp-task-manager`、`serena` 等 MCP，再按本机环境补安装。

## 更新边界

- `update` 默认不覆盖 `config.toml`
- `update` 默认不覆盖 live `AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 与 `handoff/`
- `state-templates/` 会作为模板内容被更新，但不会直接覆盖 live state
- `dry-run` 只输出会执行的动作范围，不写文件，也不提供逐文件 diff 结果
