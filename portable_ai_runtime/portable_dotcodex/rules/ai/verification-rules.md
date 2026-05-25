## AI 验证规则

### 规则优先级

- 本文件用于细化 `AGENTS.md` 里的验证与交付要求。
- 与 `AGENTS.md` 冲突时，以 `AGENTS.md` 为准。

### 宣称完成前必须做什么

每个非琐碎任务在宣称完成前，至少要：

1. 运行与任务匹配的验证命令
2. 明确写出实际运行了什么
3. 明确写出结果是什么
4. 如果要判断“是否可提交”，先运行 `repo-audit`

### 证据规则

- 没有与任务匹配的测试、构建、lint、审计或其他验证证据时，不要声称任务已完成、已修复或已通过。
- 如果本次结论依赖“没有类型/语法/配置错误”这类判断，优先补充原生 LSP 诊断证据或明确说明当前无法取得。
- 如果本次结论依赖“定义/引用/调用关系/符号边界”这类判断，优先补充 `serena` 等语义级证据或明确说明当前无法取得。

### 治理系统变更的额外验证

- 如果本次修改的是 AI 治理系统本身（如 `AGENTS.md`、`rules/ai/*`、`workflows/ai/*`、`references/ai/*`、`agents/*`、`opencode.json` 或状态文件），在宣称完成前必须运行 `workflows/ai/check-governance-consistency.md`。
- 该检查至少覆盖与本次变更相关的规则、workflow、reference、agent prompt、运行配置和状态文件；如果某一层按理应变却未改，必须明确写出原因。
- 治理一致性检查的汇报至少包含：检查范围、实际核对的文件、路径存在性结果、是否发现冲突或漂移。
- 高频治理场景优先复用 `references/ai/verification-templates.md` 的对应模板组织证据；不要在 workflow 或 guide 里各自复制一套长检查单。
- 如果本次变更触及入口壳、会话纪律、token 预算或 `opencode.json` 注入路径，额外参考 `references/ai/governance-smoke-check.md` 做一次轻量失活检查。

### 会话预算规则的额外验证

- 如果本次修改涉及会话 token 预算、长会话压缩行为、提醒文案或开新会话规则，必须同时验证三层是否对齐：顶层入口、正式规则、验证模板。
- 如果当前环境没有可编程 hook 或无法直接读取运行时 token 计数，不得把这类变更误报成“已建立强制运行时门禁”；应明确标记为“治理约束已接入，运行时执行依赖 host 暴露的上下文计数信息”。
- 如果本次还修改了 `AGENTS.md` 或 `opencode.json`，优先同时跑一遍 `references/ai/governance-smoke-check.md` 中的入口块、注入路径和阈值冲突检查。
- 如果本次已经新增了脚本实现，优先同时跑 `scripts/ai-governance-smoke-check.sh` 和 `scripts/ai-trigger-check.sh`，把文档检查和机械检查都覆盖到。
- 如果本次修改涉及 `skills/vibe/config/*.json` 的路径边界、install-time projection、external-tooling 证据面或 canonical vs installed 资产判定，额外运行 `scripts/check-vibe-config-paths.py`。

### 静态编辑 vs 运行时生效变更

- 仅修改静态文件文本、且不会改变当前真实运行行为时，可以把验证停留在文件级核对、一致性检查和路径存在性检查。
- 如果本次变更会影响运行时真实行为（例如 `serena` / 原生 LSP / MCP 可用性、agent prompt 运行面、`opencode.json` 之类需要 reload/restart/reactivate 才真正生效的配置），不得把“文件已改”当成完成证据。
- 对运行时生效变更，在宣称完成前必须补齐两类证据：
  1. 实际执行了什么 refresh / reactivate / restart
  2. refresh 之后重新采集的运行证据
- 详细判定与示例统一参考 `references/ai/runtime-refresh-rules.md`；不要把刷新规则分散重写到多个文件里。
- 如果本次属于高频运行面治理场景（如 Serena / 原生 LSP / MCP 配置、subagent routing / prompt、command-template 或 agent-prompt 变更），优先直接套用 `references/ai/verification-templates.md` 中的紧凑证据块。
- 如果本次属于会话预算治理场景（如 token 阈值、长会话提醒、重开会话规则），优先直接套用 `references/ai/verification-templates.md` 中的对应证据块。
