## 计划编写工作流

### 前提

- 本工作流由 `skills/writing-plans/SKILL.md` 路由触发。
- 计划编写的约束规则在 `rules/ai/plan-writing-rules.md`，执行前必须满足。
- 计划默认保存到 `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`（用户偏好覆盖默认值）。

### 步骤 1：宣布并确认上下文

开始即宣布：**"I'm using the writing-plans skill to create the implementation plan."**

假定读者是熟练开发者，但对我们的工具链和问题域了解甚少，也不擅长测试设计。计划应包含他们需要的所有信息：每个任务涉及的文件、代码、测试、可能需要查阅的文档以及验证方式。

### 步骤 2：范围检查

如果 spec 覆盖多个独立子系统，应已在 brainstorming 阶段拆分为子项目 spec。如果未拆分，建议拆成多个独立计划——每个计划应能独立产出可运行、可测试的软件。

### 步骤 3：文件结构映射

在定义任务之前，先映射哪些文件会被创建或修改，以及每个文件的职责。这是分解决策锁定的节点。

- 划分有清晰边界和明确接口的设计单元。
- 当结构性取舍需要用户输入时，遵循 `rules/ai/grill-me-protocol.md`。
- 此结构决定任务分解方向。每个任务应产出独立的、自包含的变更。

### 步骤 4：编写任务

按 `rules/ai/plan-writing-rules.md` 中的模板逐任务编写：

1. 每个任务使用完整的 Task 结构（Files 清单、checkbox 步骤、代码块、运行命令与预期输出）。
2. 绝不使用占位符——每个步骤都包含工程师需要的实际内容。
3. 后续任务中引用的所有类型、函数、方法都必须在计划中已定义。

### 步骤 5：自检

写出完整计划后，用新眼光对照 spec 检查计划。这是自己运行的自检清单，不是分派给子代理的任务。

1. **Spec 覆盖**：浏览 spec 的每个章节/需求。能否指出某个 Task 实现了它？列出缺口。
2. **占位符扫描**：搜索计划中的红色标记——`rules/ai/plan-writing-rules.md` 中"禁止占位符规则"列出的所有模式。修复所有发现。
3. **类型一致性**：后续任务中使用的类型、方法签名、属性名是否与前序任务中定义的匹配？如 Task 3 中叫 `clearLayers()` 而 Task 7 中叫 `clearFullLayers()` 就是 bug。

发现问题时直接 inline 修复。无需重复审查——修完即走。发现 spec 需求无对应任务时，补充任务。

### 步骤 6：执行交接

保存计划后，提供执行选择：

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

- 若选择 Subagent-Driven：使用 `subagent-driven-development`，每任务新子代理 + 两阶段审查。
- 若选择 Inline Execution：使用 `executing-plans`，批量执行带检查点。

### 与其他流程的关系

- **brainstorming** — 产生 spec/设计，writing-plans 将其转化为可执行计划。
- **fix-and-review** — 不需要完整计划；直接按修复流程执行。
- **subagent-driven-development** — 是 writing-plans 产物的推荐执行方式。
- **grill-me** — 当文件结构或架构取舍需要用户输入时调用。
