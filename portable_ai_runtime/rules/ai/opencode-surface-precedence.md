# OpenCode 表面优先级规则（opencode-surface-precedence）

### 作用

定义 OpenCode 配置面中 **Command 与 Agent 双定义（文件 vs JSON）冲突时以谁为准** 的单一权威规则。本文件是该 doctrine 的唯一正式 owner；`DECISIONS.md` 中的历史记录与本文件冲突时以本文件为准。

### 规则优先级

- 本文件用于细化 `AGENTS.md` 与 `rules/ai/routing-rules.md` 未覆盖的"配置面双定义"判定。
- 与 `AGENTS.md` 冲突时，以 `AGENTS.md` 为准。
- 实验依据：DECISIONS.md 2026-07-15 "Command 与 Agent 定义的文件/JSON 优先级"（对照实验：commands/_test.md 与 opencode.json 的 command._test、agents/vibe-plan.md 与 opencode.json 的 agent.vibe-plan，实验用文件已删除，结论仍有效）。

### Command 优先级

- `commands/*.md` 文件 **优先于** `opencode.json.command`：同名时文件覆盖 JSON。
- 新增显式命令默认写入 `commands/*.md`，不再默认接线 `opencode.json.command`（2026-05-18 的旧默认已作废，见 DECISIONS.md 同段 `已被取代` 标注）。

### Agent 优先级

- `opencode.json.agent` **优先于** `agents/*.md` 的 frontmatter 字段：同名时 JSON 覆盖文件字段。
- **未验证边界**：`agents/*.md` 的 body 内容是否与 JSON prompt 合并**尚未验证**——不得声称 body 会生效；只有 frontmatter 的 JSON 覆盖行为有实验依据。

### 禁止双定义

- 同一名称不得同时在文件面与 JSON 面各定义一份不同实现——双定义产生歧义，属 drift（除非经本文件规则明确裁定优先级）。
- 新增入口前先 grep 两侧是否已存在同名定义。

### 检验句

问自己：`当前这个 command/agent 如果同时在 commands/*.md 与 opencode.json 出现，我依据哪条规则判定谁生效？文件里是否有明确答案？`
