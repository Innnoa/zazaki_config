## OpenCode AI Governance 融合设计

日期：2026-05-09

状态：draft for review

范围：`/home/zazaki/.config/opencode`

### 1. 目标

将《如何写一个好的 skill》中的核心方法论逐步融入当前 OpenCode AI 开发环境，使现有 `AGENTS.md`、skills、MCP、命令入口与状态文件形成一套更稳定的治理层。

本设计不推倒重来，不重建平行体系，而是在现有配置之上增加显式路由、任务闭环、知识沉淀边界与验证机制。

### 2. 非目标

- 不重写现有全部 skills。
- 不一次性模板化所有能力。
- 不为所有 harness 做全量兼容层。
- 不改变现有主要使用习惯：`quick`、`vibe`、自动 skill 触发、现有 MCP 组合继续保留。

### 3. 当前状态摘要

当前环境已经具备较强基础设施：

- 顶层规则入口：`AGENTS.md`
- 可触发 skills：`brainstorming`、`writing-plans`、`verification-before-completion`、`systematic-debugging`、`context-handoff`、`vibe` 等
- MCP 工具：`serena`、`shrimp-task-manager`、`repo-audit`、`context7`、`exa_search`、`sequential-thinking`
- 状态文件约定：`CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md`、`handoff/`
- 运行时命令入口：`vibe`、`vibe-implement`、`vibe-review`

缺口不在工具能力，而在治理层：

- `AGENTS.md` 承担了过多内容，长期会膨胀
- 不同任务缺少统一、显式的文件路由
- 规则、经验、流程尚未完全分层
- 经验沉淀缺少固定闭环与录入标准
- 现有 skill 的命中表达还未被系统性校验

### 4. 设计原则

1. 结构服务于内容，不做空壳化目录。
2. 激活优于存储，规则必须出现在实际任务路径上。
3. 优先复用现有 skill 与 MCP，不新增平行能力。
4. 最先建设任务路由和闭环，再逐步模板化。
5. `AGENTS.md` 作为薄壳入口，不再继续承载所有细则。

### 5. 目标结构

在当前目录下新增治理层目录：

```text
/home/zazaki/.config/opencode/
├── AGENTS.md
├── rules/ai/
│   ├── governance-principles.md
│   ├── routing-rules.md
│   ├── task-closure.md
│   ├── recording-rules.md
│   └── verification-rules.md
├── workflows/ai/
│   ├── fix-bug.md
│   ├── implement-feature.md
│   ├── review.md
│   ├── plan.md
│   └── update-rules.md
├── references/ai/
│   ├── gotchas.md
│   ├── tool-differences.md
│   └── anti-patterns.md
├── docs/superpowers/specs/
└── handoff/
```

说明：

- `governance-principles.md` 只放长期稳定原则
- `rules/ai/` 只放长期约束
- `workflows/ai/` 只放步骤化流程
- `references/ai/` 只放高代价、可复发、代码不可直观看出的经验与差异
- `docs/superpowers/specs/` 继续作为设计文档位置

### 6. 文件职责边界

#### 6.1 AGENTS.md

保留内容：

- 规则优先级
- 高层行为原则
- skill 与 MCP 自动触发原则
- 模式选择（`quick` / `vibe`）
- 状态文件总约定
- 提交前审查红线

迁出内容：

- 具体任务步骤
- 局部高代价坑点
- 闭环细节
- 记录分类规则

#### 6.2 rules/ai/

- `governance-principles.md`：长期稳定、轻易不改的上层治理原则
- `routing-rules.md`：Always Read、Common Tasks、兜底路径
- `task-closure.md`：任务完成的定义与 AAR 四问
- `recording-rules.md`：什么内容写到哪里
- `verification-rules.md`：何时必须验证、验证结果如何汇报

#### 6.3 workflows/ai/

- `fix-bug.md`：bug 场景标准执行路径
- `implement-feature.md`：实现需求标准执行路径
- `review.md`：审查优先路径
- `plan.md`：设计与计划路径
- `update-rules.md`：任务结束后的规则更新闭环

#### 6.4 references/ai/

- `gotchas.md`：已证实的高代价坑点
- `tool-differences.md`：各 harness / tool 差异
- `anti-patterns.md`：已知会导致退化的行为模式

### 7. 任务路由设计

治理层需要给现有能力补一个显式路由表。

#### 7.1 Always Read

每个非琐碎任务默认读取：

1. `AGENTS.md`
2. 如果当前目录已经建立 `CURRENT_TASK.md`，并且任务不是纯信息问答，则读取它
3. 如果任务会复用既有技术取舍、约束、迁移背景或历史决定，则读取 `DECISIONS.md`

如果任务是对当前配置仓本身做治理修改，则再补读相关 `rules/ai/` 和 `workflows/ai/`。

#### 7.2 Common Tasks

- 修 bug：出现 bug、测试失败、构建失败、意外行为，且尚未完成根因分析时，先用 `systematic-debugging`，再按 `workflows/ai/fix-bug.md` 执行
- 实现功能：新增功能、行为修改、方案探索、需求设计，且尚未完成设计确认时先用 `brainstorming`；如果已经有设计/spec，且实现步骤达到 3 步及以上、涉及多文件修改、或需要跨轮执行，再用 `writing-plans`，随后按 `workflows/ai/implement-feature.md` 执行
- 规划或拆实施路径：按 `workflows/ai/plan.md` 执行
- 代码审查：`workflows/ai/review.md` + reviewer mindset
- `vibe` 的正式触发条件以 `rules/ai/routing-rules.md` 为准；常见命中场景包括用户明确提到 `vibe`，以及多文件修改、跨轮跟踪、冻结 requirement / plan、较强验证闭环这类复杂任务
- 多子任务且相互独立的任务：优先 `subagent-driven-development`，如果同时满足 `vibe` 条件，则优先 `vibe`
- 提交前完成确认：应用 `rules/ai/verification-rules.md`，并在需要判断“是否可提交”时先运行 `repo-audit`
- 未分类任务：先应用 Always Read，再选择最接近的 workflow，并在汇报里明确说明匹配原因

如果一个任务同时命中多个路径，优先顺序为：安全/阻断风险 > `vibe` 受管运行时 > 明确 workflow > 兜底路径。

#### 7.3 推荐路由原则

路由不直接替代现有 skills，而是定义调用顺序与上下文补充方式。

任务路由判定细节以 `rules/ai/routing-rules.md` 为单一权威源；本设计文档保留摘要和设计意图，不重复维护全部细节文案。

`AGENTS.md` 负责顶层自动触发意图，`rules/ai/routing-rules.md` 负责任务路径细化，两者必须保持一致但不重复维护全部细节。

### 8. MCP 融入方式

当前 MCP 可以高兼容融入，但应赋予固定职责。

#### 8.1 serena

定位：语义级代码理解、跨文件分析、精确改动。

默认进入：

- `fix-bug`
- `implement-feature`
- `review`

#### 8.2 shrimp-task-manager

定位：复杂任务拆分、执行跟踪、验证辅助。

默认进入：

- 多步骤任务
- 长链路治理类任务
- 需要持续追踪的迁移工作

#### 8.3 repo-audit

定位：提交前门禁。

默认进入：

- commit 判断前
- “是否可提交”类结论前

#### 8.4 context7

定位：官方文档校准。

默认进入：

- 新库接入
- API 变化确认
- 文档真实性核对

#### 8.5 exa_search

定位：开放网络研究。

默认进入：

- 生态对比
- 方案调研
- 外部最佳实践收集

#### 8.6 sequential-thinking

定位：高歧义推理问题。

默认进入：

- 复杂判断
- 多路径取舍
- 棘手调试分析

### 9. Skills 融入方式

现有 skills 与本设计高度兼容，不建议重写，只建议加治理层约束。

#### 9.1 brainstorming

继续承担设计前置阶段；新增功能、行为修改、方案探索、需求设计，且尚未完成设计确认时应自动触发。

增加要求：

- 明确设计文档落点
- 明确与 `writing-plans` 的衔接

#### 9.2 writing-plans

继续承担计划制定；已经有设计/spec，且实现步骤达到 3 步及以上、涉及多文件修改、或需要跨轮执行时，应被显式触发。

#### 9.3 systematic-debugging

作为 bug 路由中的默认第一环；出现 bug、测试失败、构建失败、意外行为，且尚未完成根因分析时应自动触发，避免直接拍脑袋修。

#### 9.4 verification-before-completion

作为 `task-closure.md` 的执行性补足；准备声称任务完成、问题已修复、结果已通过、或准备进入提交判断前应自动触发，成为非 trivial 任务默认出口之一。

#### 9.5 context-handoff

作为状态外化与跨轮连续性的主工具，不替代 `recording-rules.md`，而是按规则写入对应位置。

#### 9.6 subagent-driven-development

保留为明确路由能力，不设为默认模式，符合现有“无用户授权不自行展开多代理”的原则；仅在多子任务且相互独立时优先，若同时命中 `vibe` 条件，则让位给 `vibe`。

#### 9.7 vibe

作为复杂任务的受管运行时总入口；凡是任务涉及多文件修改、跨轮跟踪、冻结 requirement/plan、较强验证闭环，或用户明确提到 `vibe`，必须进入该路径。优先服务：

- 多文件修改
- 跨轮跟踪
- 高验证要求
- 设计和计划需要冻结的任务

### 10. 任务闭环设计

引入轻量版 AAR，不增加过重负担。

#### 10.1 任务完成定义

一个非琐碎任务在以下条件全部满足前不算完成：

1. 主体工作完成
2. 执行了必要验证
3. 过了一遍 AAR 四问
4. 如有新经验，则按规则写入正确位置

每个非琐碎任务在宣称完成前，都必须经过一次闭环检查。闭环检查至少包含：验证结果确认、AAR 四问、是否需要更新规则或记录。

#### 10.2 AAR 四问

1. 这次有没有新坑？
2. 有没有缺失规则？
3. 有没有过时规则？
4. 有没有应该复用的验证步骤？

如果四问都为否，则不强制追加文档。

如果四问全部为“没有”，也要明确得出“本次无新增规则或坑点”的结论，而不是只写“已检查”。

#### 10.3 跳过条件

仅以下场景可跳过新增规则或新增记录：

- 纯格式化
- 纯注释修改
- 纯依赖版本调整
- 无新经验的行为等价重构

这些场景不是天然免检查，而是只允许走轻闭环。进入跳过路径前，仍需先确认：没有新的高代价坑点、没有新的规则缺口、没有新的验证结论值得复用。

### 11. 记录位置规则

建议固定以下边界：

- 当前目标、状态、下一步：`CURRENT_TASK.md`
- 可复用技术决策：`DECISIONS.md`
- 项目级审计结论、关键验证锚点、跨轮增量：`AI_GUIDE.md`
- 会话交接：`handoff/`
- 稳定约束：`rules/ai/`
- 高代价坑点：`references/ai/`
- 步骤流程：`workflows/ai/`
- 会话日志、过程叙事：不要写进 skill / rules / references，优先用 git 历史或单独文档

### 12. 验证规则

验证规则需要从“建议”升级为“路径要求”。

每个非 trivial 任务在宣称完成前，应：

1. 运行对应验证命令
2. 记录实际运行了什么
3. 明确说明结果
4. 如涉及提交判断，先过 `repo-audit`

### 13. 分阶段落地计划

#### Phase 1：治理骨架

- 新增 `rules/ai/`
- 新增 `workflows/ai/`
- 新增 `references/ai/`
- 将 `AGENTS.md` 中可迁移的细则抽离

#### Phase 2：统一路由

- 定义 Always Read
- 定义 Common Tasks
- 将现有 skills 与 MCP 编入固定任务路径

#### Phase 3：闭环化

- 非琐碎任务必须经过闭环检查
- AAR 四问全部为“没有”时也要得出明确结论
- 可跳过场景不是免检查，而是窄场景下的轻闭环

#### Phase 4：命中率与质量优化

- 检查关键 skills 的 `description`
- 优化自动触发表达
- 补充 `gotchas.md` 与 `tool-differences.md`

#### Phase 5：最小命中率验证

- 建立人工 trigger-check 流程
- 用小样本校对常见任务表述的推荐命中路径
- 先做人工小样本抽查/回归，不急于上自动化脚本，也不把这一阶段当作正式命中率统计框架

### 14. 风险与权衡

#### 风险

- 前期目录增加，可能带来轻微使用负担
- 如果治理文件写得太泛，会重新回到“大文件空规则”问题
- 如果过早模板化，容易变成形式完整、内容空心

#### 权衡

- 先做骨架和边界，不做大规模内容迁移
- 先让任务路由成立，再优化触发精度
- 先服务当前主路径，不追求一次性多 harness 全覆盖

### 15. 推荐决策

推荐采用“基于现有体系的渐进式框架化”方案：

- 不推翻现有 `AGENTS.md`
- 不重写现有 skills 和 MCP 配置
- 通过新增治理层目录，把任务路由、闭环、知识沉淀与验证规则显式化

这样既能吸收文章精华，也不会破坏你当前已经可用的 AI 开发环境。

### 16. 当前实现建议

建议下一步进入实现计划阶段，先做最小治理骨架：

1. 建立 `rules/ai/`、`workflows/ai/`、`references/ai/`
2. 起草 `routing-rules.md`、`task-closure.md`、`recording-rules.md`
3. 起草 `fix-bug.md`、`review.md`、`update-rules.md`
4. 精简 `AGENTS.md` 的职责边界，但暂不大改内容
5. 再评估哪些现有 skills 的 `description` 需要补充

### 17. 备注

本目录不是 git 仓库，因此当前设计文档无法按默认流程提交 commit。后续如需版本化，应将相关治理文件纳入一个受 git 管理的配置仓或目标项目仓。
