# OpenCode AI Governance Phase 3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把闭环规则从“定义存在”推进到“可稳定执行”，并为经验沉淀建立最小可用示例锚点。

**Architecture:** 本阶段不扩张治理目录，不修改 MCP 配置，也不大规模填充 reference 内容。重点是增强 `task-closure.md`、`update-rules.md`、`AI_GUIDE.md` 与 `references/ai/*` 的联动，让 AAR、记录位置判断和最小示例沉淀形成可直接复用的工作流。

**Tech Stack:** Markdown 文档、现有治理规则文件、状态文件体系

---

### Task 1: Strengthen Task Closure Rules With An Explicit Execution Contract

**Files:**
- Modify: `rules/ai/task-closure.md`
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md`

- [ ] **Step 1: Read the current closure rules and closure section in the design spec**

Run: `rg -n "AAR|闭环|跳过|完成定义|记录位置" "/home/zazaki/.config/opencode/rules/ai/task-closure.md" "/home/zazaki/.config/opencode/docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md"`
Expected: the current closure language is shown from both files.

- [ ] **Step 2: Add an explicit execution contract to `rules/ai/task-closure.md`**

Insert this section after `### 完成定义`:

```md
### 执行契约

- 每个非琐碎任务在宣称完成前，都必须经过一次闭环检查。
- 闭环检查至少包含：验证结果确认、AAR 四问、是否需要更新规则或记录。
- 如果任务属于可跳过的窄场景，也必须先判断它是否真的属于该窄场景，而不是直接跳过。
```

- [ ] **Step 3: Tighten the AAR wording so it is more operational**

Replace the current `### AAR 最低执行要求` block with:

```md
### AAR 最低执行要求

- AAR 四问必须逐条检查一遍。
- 四问全部为“没有”时，明确记录“本次无新增规则或坑点”。
- 任意一问为“有”时，继续按 `workflows/ai/update-rules.md` 判断写入位置。
- 不允许只回答“已检查”而不说明是否有新增结论。
```

- [ ] **Step 4: Tighten the skip section so it cannot be overused**

Replace the current `### 可跳过的窄场景` block with:

```md
### 可跳过的窄场景

只有以下场景可以跳过较重的闭环记录：

- 纯格式化
- 纯注释修改
- 纯依赖版本调整
- 没有新经验的行为等价重构

即使属于这些场景，也要先确认：

- 没有新的高代价坑点
- 没有新的规则缺口
- 没有新的验证结论值得复用
```

- [ ] **Step 5: Sync the design spec closure section with the stronger closure contract**

Update the closure section in `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` so that it explicitly reflects:

- 非琐碎任务必须经过闭环检查
- AAR 四问全部为“没有”时也要得出明确结论
- 可跳过场景不是“天然免检查”，而是窄场景下的轻闭环

- [ ] **Step 6: Verify the new closure phrases exist**

Run: `rg -n "执行契约|本次无新增规则或坑点|不允许只回答|即使属于这些场景" "/home/zazaki/.config/opencode/rules/ai/task-closure.md"`
Expected: all tightened closure phrases are present.

### Task 2: Make Update-Rules Workflow Actionable

**Files:**
- Modify: `workflows/ai/update-rules.md`
- Modify: `rules/ai/recording-rules.md`

- [ ] **Step 1: Read the current update-rules workflow and recording rules**

Run: `rg -n "更新规则工作流|记录位置|记录格式|录入门槛|当前配置目录状态" "/home/zazaki/.config/opencode/workflows/ai/update-rules.md" "/home/zazaki/.config/opencode/rules/ai/recording-rules.md"`
Expected: the current workflow and recording-rule sections are shown.

- [ ] **Step 2: Expand `workflows/ai/update-rules.md` into a more explicit 5-step flow**

Replace the current file body with:

```md
## 更新规则工作流

1. 先运行 `rules/ai/task-closure.md` 里的 AAR 四问
2. 如果四问全部为“没有”，在当前任务汇报中明确写出“本次无新增规则或坑点”，然后停止
3. 如果任意一问为“有”，先判断该结论属于：规则、坑点、决策、状态更新、还是项目级锚点
4. 按 `rules/ai/recording-rules.md` 的记录位置规则选择落点，并优先使用最轻的正确记录格式
5. 不要把会话叙事或原始调试过程写进治理 reference 文件
```

- [ ] **Step 3: Add a short “快速判断” section to `rules/ai/recording-rules.md`**

Append this section after `### 新规则或新坑点的录入门槛`:

```md
### 快速判断

- 当前执行状态变化：写 `CURRENT_TASK.md`
- 可复用取舍变化：写 `DECISIONS.md`
- 项目级验证锚点或跨轮增量：写 `AI_GUIDE.md`
- 高代价、可复发坑点：写 `references/ai/`
- 稳定治理约束变化：写 `rules/ai/`
- 有顺序的执行步骤变化：写 `workflows/ai/`
```

- [ ] **Step 4: Add one sentence clarifying that `references/ai/*` should start sparse**

Append this bullet under `### 记录格式优先级`:

```md
- `references/ai/*` 初期保持稀疏，只有出现真实高价值样本时才新增条目。
```

- [ ] **Step 5: Verify the update workflow now requires an explicit “no new rules” statement**

Run: `rg -n "本次无新增规则或坑点|先判断该结论属于|快速判断|初期保持稀疏" "/home/zazaki/.config/opencode/workflows/ai/update-rules.md" "/home/zazaki/.config/opencode/rules/ai/recording-rules.md"`
Expected: all four phrases are present.

### Task 3: Add Minimal Example Anchors Without Overfilling References

**Files:**
- Modify: `references/ai/gotchas.md`
- Modify: `references/ai/tool-differences.md`
- Modify: `references/ai/anti-patterns.md`
- Modify: `AI_GUIDE.md`

- [ ] **Step 1: Add one minimal example anchor to `references/ai/gotchas.md`**

Append this example section:

```md
## 示例锚点

- Context 压缩后如果只剩顶层摘要而没有显式路由表，任务容易错误继承上一轮路径；这类问题应优先通过路由文件和薄壳入口解决，而不是靠记忆补救。
```

- [ ] **Step 2: Add one minimal example anchor to `references/ai/tool-differences.md`**

Append this example section:

```md
## 示例锚点

- 非 git 目录下无法提供 `git diff` 级别的变更证据，这会限制“只修改了哪些文件”的严格审查能力。
```

- [ ] **Step 3: Add one minimal example anchor to `references/ai/anti-patterns.md`**

Append this example section:

```md
## 示例锚点

- 把路由细节、记录位置和读取顺序同时写进 `AGENTS.md` 与下层规则文件，会快速制造双重维护和漂移。
```

- [ ] **Step 4: Add a Phase 3 anchor to `AI_GUIDE.md`**

Append this section:

```md
### 2026-05-09 - Governance Phase 3 closure workflow tightened

- 已强化 `task-closure.md` 与 `update-rules.md` 的闭环执行契约
- 已为 `references/ai/*` 增加最小示例锚点，但仍保持稀疏
- 后续经验沉淀应优先走轻量记录，而不是一次性堆满 references
```

- [ ] **Step 5: Verify the reference files now have exactly one example-anchor section each**

Run: `rg -n "## 示例锚点" "/home/zazaki/.config/opencode/references/ai/gotchas.md" "/home/zazaki/.config/opencode/references/ai/tool-differences.md" "/home/zazaki/.config/opencode/references/ai/anti-patterns.md"`
Expected: one match in each file.

### Task 4: Validate Phase 3 Outputs

**Files:**
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` only if a clear mismatch remains after implementation

- [ ] **Step 1: Check for unresolved markers in Phase 3 touched files**

Run: `rg -n "TODO|TBD|FILL" "/home/zazaki/.config/opencode/rules/ai/task-closure.md" "/home/zazaki/.config/opencode/workflows/ai/update-rules.md" "/home/zazaki/.config/opencode/rules/ai/recording-rules.md" "/home/zazaki/.config/opencode/references/ai/gotchas.md" "/home/zazaki/.config/opencode/references/ai/tool-differences.md" "/home/zazaki/.config/opencode/references/ai/anti-patterns.md" "/home/zazaki/.config/opencode/AI_GUIDE.md"`
Expected: no matches.

- [ ] **Step 2: Check that the design spec still matches the closure and recording model**

Run: `rg -n "闭环|AAR|记录位置|AI_GUIDE.md|references/ai|update-rules.md" "/home/zazaki/.config/opencode/docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md"`
Expected: the design still reflects the stronger closure contract and recording model.

- [ ] **Step 3: Check that Phase 3 reference files remain sparse rather than bloated**

Run: `wc -l "/home/zazaki/.config/opencode/references/ai/gotchas.md" "/home/zazaki/.config/opencode/references/ai/tool-differences.md" "/home/zazaki/.config/opencode/references/ai/anti-patterns.md"`
Expected: each file remains short and focused.

- [ ] **Step 4: Record validation outcome in the final summary**

Include in final report:

```text
Validation run:
- phase 3 unresolved marker scan: pass/fail
- closure contract check: pass/fail
- update-rules actionability check: pass/fail
- reference sparsity check: pass/fail
```

- [ ] **Step 5: Commit only if this directory becomes a git repository before execution time**

```bash
git add rules/ai/task-closure.md workflows/ai/update-rules.md rules/ai/recording-rules.md references/ai/gotchas.md references/ai/tool-differences.md references/ai/anti-patterns.md AI_GUIDE.md docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md docs/superpowers/plans/2026-05-09-opencode-ai-governance-phase-3.md
git commit -m "docs: strengthen AI closure and recording flow"
```

If the directory is still not a git repository, skip commit and state that commit was not possible in the execution summary.
