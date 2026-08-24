## AI 路由规则

### 作用

定义当前 OpenCode 环境里，非琐碎 AI 任务默认应读取哪些文件、走哪条任务路径。

### 优先级

- 本文件用于细化 `AGENTS.md`；与 `AGENTS.md` 冲突时，以 `AGENTS.md` 为准。
- 本文件只负责任务级路由，不重复顶层行为原则。
- 涉及任务路由判定细节时，本文件是单一权威源；设计文档和 `AGENTS.md` 只保留摘要或入口说明。
- `references/ai/trigger-phrases.md` 仅用于人工校对常见表述与推荐路径，不替代本文件的正式路由规则。

### 会话纪律

以下 Always Read 与路由检查两部分共同定义本文件的会话纪律规则；token 预算阈值与长会话提醒的详细语义以 `references/ai/session-budget-rules.md` 为准。

### Always Read

1. 总是先读 `AGENTS.md`
2. 对非纯信息问答任务，总是再读本文件的"会话纪律"部分
3. 如果当前目录已经建立 `CURRENT_TASK.md`，并且任务不是纯信息问答，则读取它
4. 如果读取后发现 `CURRENT_TASK.md` 明显描述的是别的任务，先把它刷新为当前任务，再继续实质工作
5. 如果任务会复用既有技术取舍、约束、迁移背景或历史决定，则读取 `DECISIONS.md`
6. 如果任务是对当前配置仓本身做治理修改，再补读相关 `rules/ai/` 和 `workflows/ai/`

### Common Tasks

#### 默认路径：非琐碎工作 → `vibe`

任何满足以下任一条件的任务，默认走 `vibe` 受管运行时：
- 涉及 2+ 文件修改
- 可能需要跨会话继续（无法一次完成）
- 涉及新的设计决策（不仅是纯机械执行）
- 处于治理系统本身（`$HOME/.config/opencode` 下的工作）

vibe 的 6 阶段合约（skeleton_check → deep_interview → requirement_doc → xl_plan → plan_execute → phase_cleanup）统一覆盖 brainstorming、writing-plans、subagent-driven-development 等场景，无需手动逐一选择路由。

#### 不走 vibe 的专用路径

以下场景使用专用路径，不经过 vibe：
- 修 bug（已知根因）：`systematic-debugging` → `workflows/ai/fix-and-review.md`
- 纯信息问答/查资料：直接回答，不走任何 workflow
- 代码审查：`workflows/ai/fix-and-review.md`，保持 reviewer mindset
- UI/UX 设计/审查：`ux-design` skill
- 单文件小改（<20 行，纯执行，无设计决策）：直接执行
- 需要跨会话粘贴提示词：`/new-session`
- 多子任务且相互独立、但无需冻结需求/计划的轻量任务：`subagent-driven-development`

#### 其他

- 用户明确提到 `vibe`：必须走 `vibe`
- 涉及“修改后是否引入类型/语法/配置错误”“某个文件当前有哪些诊断”“需要定义跳转/引用/hover”这类问题时，优先使用 OpenCode 原生 LSP 相关能力获取诊断或查询证据
- 涉及“跨文件语义定位”“符号级理解”“引用关系确认”“结构化改动”这类问题时，优先使用 `serena`
- 提交前完成确认：应用 `rules/ai/verification-rules.md`，并在需要判断“是否可提交”时先运行 `repo-audit`
- 设计/审查 UI/UX：加载 `ux-design` skill，按 skill 内部 Common Tasks 路由到对应规则层逐条审查
- 未分类任务：先应用 Always Read，再选择最接近的 workflow，并在汇报里明确说明匹配原因

### 路由检查

- 新任务默认先重读 `AGENTS.md`，并按本文件"会话纪律"重新路由。
- 当任务目标从修 bug 变成实现、审查、规划或治理时，必须重新匹配本文件中的任务路径。
- 如果没有完全匹配的 workflow，必须说明采用了哪个最接近的 workflow，以及为什么这样选。
- 如果一个任务同时命中多个路径，优先顺序为：安全/阻断风险 > `vibe` 受管运行时 > 明确 workflow > 兜底路径。
- 如果任务发生在 `$HOME/.config/opencode` 本身，默认应读取这里的 `CURRENT_TASK.md`。
- 准备使用多 agent / subagent 前，先执行 `workflows/ai/subagent-routing.md`；信息不足时先串行探索，再决定是否并行。
- 当对 trigger wording 是否准确有疑问时，参考 `references/ai/trigger-phrases.md` 做快速校对。

### 检验句

问自己：`我当前走的路径，和 routing-rules.md 里对这个任务类型的说明完全一致吗？`
如果自己的判断和文件里写的不一样，以文件为准，不要自行"优化"路由。
