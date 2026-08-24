## 自动 Human Writing 触发规则

### 作用

指示 AI 在用户进行中文写作创作（尤其网络小说）时，自动加载 `human-writing` skill（活人感写作），无需用户显式说明。

### 自动触发条件

以下任一情况自动激活 `human-writing` skill：

| 触发场景 | 处理 |
|---|---|
| 网络小说/网文创作：写章节、码字更新、续写、爽文、系统文、金手指文 | `human-writing` |
| 小说/故事/虚构创作：人物、场景、对白、情节、世界观 | `human-writing` |
| 知乎回答、公众号文章、论坛长帖、博客、评测、科普、教程等中文长文 | `human-writing` |
| 用户要求"写得像人写的"、"有活人感"、"自然中文韵律"的创作型稿件 | `human-writing` |

### 不触发

- 用户仅要求对已有文本去 AI 味改写：用 `humanizer-zh`（去痕改写），不加载 `human-writing`
- 技术文档、代码注释、短事实性回答：两者都不用
- 用户明确指定使用其他 skill 或直接要求"别用 skill"：听用户的

### 自动执行规则

1. 加载 `human-writing` skill，按其内置工作流执行：材料门槛检查 → 现实/虚构分流 → 按任务读取对应 `skills/human-writing/references/`（小说读 `skills/human-writing/references/fiction.md`，帖子体小说同时读 `skills/human-writing/references/forum-prose.md`）→ 初稿 → 读完初稿后读 `skills/human-writing/references/revision.md` 逐项改稿。
2. 网文场景注意：`human-writing` 提供的是人物、场景、对白、推进的文学性基底，爽点节奏、章末钩子等网文范式由创作主体（用户或当前会话）把控，不要因为 skill 未显式覆盖就丢掉网文范式。
3. 成稿硬禁令（禁冒号/破折号/翻案腔/三项排比等）由 skill 自身规则执行，初稿后按禁令检查；可选运行 `skills/human-writing/scripts/check_prose.py <稿件路径>` 清零硬禁令。
4. 长稿创作时，若用户后续要求去 AI 味，可在 `human-writing` 成稿后用 `humanizer-zh` 做二次去痕；两者定位不同（创作 vs 改写），不要混用。

### POV 视角写作法（默认叠加约束）

`pov-writing` 是创作期的严格信息边界规则，叠加于 `human-writing` 之上，**小说/网文/故事创作默认生效**：

- 默认触发：创作场景自动锁定视角人物（正在感知、行动、对话的人），只写他亲历/已知/可推断/自身心理的信息，禁止视角外信息（他人心理、视角外场景、未来事件、作者全知）；全知视角需用户明确要求
- 显式强化：用户提到"切换到XX的视角"、"从XX的角度写"、"XX看着"、"以XX的口吻/说话"、"只写某人知道的信息"、"视角写作法"、"POV"、"严格/限制视角"时，锁定该人物视角
- 优先级：POV 信息边界规则**覆盖** `human-writing` 默认写法，最高优先；`human-writing` 的材料门槛/分文体/改稿流程继续可用
- 视角信息库：随稿件目录**默认创建/更新**——锁定视角人物时检查 `pov/<人物名>.md`，不存在则按模板创建（模板见 `skills/pov-writing/SKILL.md`），存在则读取并在信息/属性变化时更新；档案用固定格式并带版本戳（`版本：vN`，每次更新 +1）

### 与 humanizer-zh 的分工与融合

两个 skill 规则同向不互斥（都去 AI 味、追活人感）：`human-writing` 是创作期 0 容忍硬禁令（禁冒号/破折号/翻案腔/三项排比），`humanizer-zh` 是改写期量化门槛（二分对照 ≤1、路标词 ≤2 等）。两者同时命中时取严者执行，不会互相推翻。

创作管线（按阶段选一个 skill，不同时跑两套）：

1. **创作**（从材料/想法/续写出发）：`human-writing`。材料门槛 → 分文体 → 初稿 → `skills/human-writing/references/revision.md` 改稿 → 硬禁令清零。
2. **改稿**（已有文本去 AI 味）：`humanizer-zh`。量化门槛 + 局部修补；"结构坏掉整段重写"只用于来源不明的旧稿。
3. **二次去痕**（`human-writing` 成稿后再要"更自然"）：`humanizer-zh` 只做量化门槛核对与局部修补，**不得重排结构**——`human-writing` 的段落/文体设计是创作意图，`humanizer-zh` 的检查项在成稿上必然已满足，只清残留即可。

触发消解：

- 请求含"写/续写/创作/码字/更新/写一章" + 文体词 → `human-writing`
- 请求含"改/润色/去AI味/太AI/不自然/像人写的" + 已有文本 → `humanizer-zh`
- 模糊场景（如"把这章改自然点"）：先看文本来源——本会话 `human-writing` 产出的创作稿 → `humanizer-zh` 局部修补；来源不明的旧稿 → `humanizer-zh` 全套流程。

### 检验句

用户要"写/续写/更新小说、网文或中文长文"时，问自己：这是创作型任务吗？如果是，是否已加载 `human-writing` skill 并按它的工作流执行？
