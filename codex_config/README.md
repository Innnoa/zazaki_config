# Codex Config Portable Pack

这个目录是从当前 `~/.codex` 提取出来的“可移植版”配置包，用于在别的设备上复用规则、模板和主配置骨架。

## 目录说明

- `portable_dotcodex/`：建议同步到新设备 `~/.codex/` 的内容。
- `portable_dotcodex/config.template.toml`：脱敏后的 `config.toml` 模板，需要手动补 token 和本机路径。
- `portable_dotcodex/state-templates/`：`AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 模板。
- `excluded/`：说明哪些当前机器状态被故意排除。
- `install.sh`：可选安装脚本，会把 `portable_dotcodex/` 复制到目标 `~/.codex/`。

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
- `docs/requirements/README.md`
- `docs/plans/README.md`

## 未包含

- 真实 token、密钥和其他敏感字段
- 当前机器的 `[projects."..."] trust_level` 清单
- `tmp/`、`outputs/runtime/vibe-sessions/`
- `.vibeskills/install-ledger.json`、`.vibeskills/mcp-auto-provision.json`
- 当前机器的 `AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md` 实时内容

## 建议用法

1. 把整个 `codex_config/` 目录带到新设备。
2. 在新设备执行 `./install.sh`，或手动把 `portable_dotcodex/` 内容复制到 `~/.codex/`。
3. 打开 `~/.codex/config.toml`，补齐 token、provider、项目 trust 和本机路径。
4. 按需要从 `state-templates/` 初始化 `AI_GUIDE.md`、`CURRENT_TASK.md`、`DECISIONS.md`。
5. 若新设备也要用 `shrimp-task-manager`、`serena` 等 MCP，再按本机环境补安装。
