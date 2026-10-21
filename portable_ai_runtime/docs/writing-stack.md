# 写作能力总览（Writing Stack）

面向小说、网文、中文长文创作的统一入口。本文件是写作能力的索引与工作流说明书，不替代任何 skill 或规则，只回答"写作任务用什么、怎么走"。

> 治理系统默认面向代码任务；写作能力是并行的一套栈，走本索引，不与代码路由混用。

## 能力全景

| 层 | 名称 | 位置 | 干什么 |
|---|---|---|---|
| 创作引擎 | `human-writing` | `skills/human-writing/` | 从材料/想法开始写小说、网文、知乎、公众号、博客等；含分文体规则（fiction / forum-prose / reality / formats） |
| 视角约束 | `pov-writing` | `skills/pov-writing/` | 严格 POV：只写视角人物知道的信息，小说创作默认触发，叠加于创作引擎，最高优先 |
| 改稿维修 | `humanizer-zh` | `skills/humanizer-zh/` | 对已有文本去 AI 味、润色、量化门槛检查（12 条硬门槛 + 24 种模式） |
| 硬检查 | `check_prose.py` | `skills/human-writing/scripts/` | 成稿硬禁令清零（冒号/破折号/翻案腔/三项排比），纯 stdlib |
| 自动触发 | `auto-trigger-rules.md` | `rules/ai/` | 网文/小说/中文长文创作场景自动加载 `human-writing` |
| 自动触发 | `auto-trigger-rules.md` | `rules/ai/` | 去 AI 味改写场景自动加载 `humanizer-zh` |
| 辅助 | `gptimage2-prompting` | `skills/gptimage2-prompting/` | 文生图提示词（小说插画/封面） |
| 辅助 | `brainstorming` | `skills/brainstorming/` | 开写前的创意、设定、结构讨论 |
| 辅助 | `grill-me` | `skills/grill-me/` | 逐个确认设定、世界观、决策点 |

## 工作流

1. **创作**：`human-writing`（材料门槛 → 现实/虚构分流 → 按任务读分文体 references → 初稿 → `skills/human-writing/references/revision.md` 改稿）
2. **改稿**（可选）：`humanizer-zh` 二次去痕——只做量化核对与局部修补，不重排结构（保住创作期文体设计）
3. **检查**（可选）：`skills/human-writing/scripts/check_prose.py <稿件路径>` 清零硬禁令

## 触发方式

- **自动**：新会话中用户请求命中 `human-writing` / `humanizer-zh` 的 description 或对应 auto 规则即加载，无需显式调用
- **显式**：`使用 $human-writing，把我的材料写成一篇有活人感的作品`
- **触发消解**：创作词（写/续写/码字/更新 + 文体）→ `human-writing`；改稿词（改/润色/去AI味 + 已有文本）→ `humanizer-zh`；模糊场景看文本来源，详见 `rules/ai/auto-trigger-rules.md`

## 边界与分工

- `human-writing` 提供文学性基底（人物/场景/对白/推进），网文爽点节奏、章末钩子由创作主体把控，skill 不负责
- `humanizer-zh` 只改文本不创作；`human-writing` 只创作不替代改稿
- 成稿硬禁令（禁冒号/破折号/翻案腔等）针对中文长文创作稿，不适用于技术文档、代码注释、短事实回答
