## AI 路由规则

### 作用

定义当前 OpenCode 环境里，非琐碎 AI 任务默认应读取哪些文件、走哪条任务路径。

### 优先级

- 本文件用于细化 `AGENTS.md`；与 `AGENTS.md` 冲突时，以 `AGENTS.md` 为准。
- 本文件只负责任务级路由，不重复顶层行为原则。
- 涉及任务路由判定细节时，本文件是单一权威源；设计文档和 `AGENTS.md` 只保留摘要或入口说明。
- `references/ai/trigger-phrases.md` 仅用于人工校对常见表述与推荐路径，不替代本文件的正式路由规则。

### Always Read

1. 总是先读 `AGENTS.md`
2. 对非纯信息问答任务，总是再读 `rules/ai/session-discipline.md`
3. 如果当前目录已经建立 `CURRENT_TASK.md`，并且任务不是纯信息问答，则读取它
4. 如果读取后发现 `CURRENT_TASK.md` 明显描述的是别的任务，先把它刷新为当前任务，再继续实质工作
5. 如果任务会复用既有技术取舍、约束、迁移背景或历史决定，则读取 `DECISIONS.md`
6. 如果任务是对当前配置仓本身做治理修改，再补读相关 `rules/ai/` 和 `workflows/ai/`

### Common Tasks

- 修 bug：出现 bug、测试失败、构建失败、意外行为，且尚未完成根因分析时，先用 `systematic-debugging`，再按 `workflows/ai/fix-bug.md` 执行
- 实现功能：新增功能、行为修改、方案探索、需求设计，且尚未完成设计确认时先用 `brainstorming`；如果已经有设计/spec，且实现步骤达到 3 步及以上、涉及多文件修改、或需要跨轮执行，再用 `writing-plans`，随后按 `workflows/ai/implement-feature.md` 执行
- 规划或拆实施路径：按 `workflows/ai/plan.md` 执行
- 需要把当前会话整理成新会话可直接粘贴的提示词时：优先使用 `/new-session`
- 代码审查：按 `workflows/ai/review.md` 执行，并保持 reviewer mindset
- 用户明确提到 `vibe`，或任务涉及多文件修改、跨轮跟踪、需要冻结 requirement / plan、或需要更强验证闭环的任务：必须走 `vibe`
- 多子任务且相互独立的任务：优先 `subagent-driven-development`，如果同时满足 `vibe` 条件，则优先 `vibe`
- 涉及“修改后是否引入类型/语法/配置错误”“某个文件当前有哪些诊断”“需要定义跳转/引用/hover”这类问题时，优先使用 OpenCode 原生 LSP 相关能力获取诊断或查询证据
- 涉及“跨文件语义定位”“符号级理解”“引用关系确认”“结构化改动”这类问题时，优先使用 `serena`
- 提交前完成确认：应用 `rules/ai/verification-rules.md`，并在需要判断“是否可提交”时先运行 `repo-audit`
- 未分类任务：先应用 Always Read，再选择最接近的 workflow，并在汇报里明确说明匹配原因

### 路由检查

- 新任务默认先重读 `AGENTS.md` 与 `rules/ai/session-discipline.md`；会话纪律细节不在本文件重写。
- 当任务目标从修 bug 变成实现、审查、规划或治理时，必须重新匹配本文件中的任务路径。
- 如果没有完全匹配的 workflow，必须说明采用了哪个最接近的 workflow，以及为什么这样选。
- 如果一个任务同时命中多个路径，优先顺序为：安全/阻断风险 > `vibe` 受管运行时 > 明确 workflow > 兜底路径。
- 如果任务发生在 `/home/zazaki/.config/opencode` 本身，默认应读取这里的 `CURRENT_TASK.md`。
- 准备使用多 agent / subagent 前，先执行 `workflows/ai/subagent-routing.md`；信息不足时先串行探索，再决定是否并行。
