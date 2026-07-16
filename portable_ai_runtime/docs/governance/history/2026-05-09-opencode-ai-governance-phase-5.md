# OpenCode AI Governance Phase 5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立一套最小、可重复执行的人工命中率验证机制，用来校对常见任务表述是否会命中预期 skill 或路径。

**Architecture:** 本阶段不引入脚本，不依赖自动化 harness，而是在现有 trigger wording、routing rules、trigger phrase 对照表基础上，增加人工验证流程、样本分组、记录格式和结果落点。这样可以先用低成本方式开始做命中率回归，而不会过早引入新的运行复杂度。

**Tech Stack:** Markdown 文档、现有治理规则、trigger phrase 对照表、AI_GUIDE 状态锚点

---

### Task 1: Add A Manual Trigger-Check Workflow

**Files:**
- Create: `workflows/ai/trigger-check.md`
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md`

- [ ] **Step 1: Create `workflows/ai/trigger-check.md` with a minimal manual verification workflow**

Create this exact content:

```md
## Trigger Check Workflow

1. 先选一组常见任务表述样本
2. 对每条样本先写出“预期命中路径”
3. 对照 `AGENTS.md`、skill `description`、`rules/ai/routing-rules.md` 做人工校对
4. 记录结果为：命中 / 部分命中 / 未命中
5. 如果未命中，优先判断应该调整的是：`AGENTS.md`、skill description、还是 `trigger-phrases.md`
6. 不要为了通过单条样本而把触发规则写得过宽
```

- [ ] **Step 2: Add a short Phase 5 note to the design spec**

Append this bullet set under the phased rollout section:

```md
#### Phase 5：最小命中率验证

- 建立人工 trigger-check 流程
- 用小样本校对常见任务表述的推荐命中路径
- 先做人工回归，不急于上自动化脚本
```

- [ ] **Step 3: Verify the new trigger-check workflow exists**

Run: `rg -n "Trigger Check Workflow|命中 / 部分命中 / 未命中|不要为了通过单条样本而把触发规则写得过宽" "/home/zazaki/.config/opencode/workflows/ai/trigger-check.md"`
Expected: all key trigger-check phrases are present.

### Task 2: Expand Trigger Samples Into A Small Manual Check Set

**Files:**
- Modify: `references/ai/trigger-phrases.md`

- [ ] **Step 1: Replace the current simple table with a richer manual-check table**

Replace the current table with this exact structure:

```md
| 常见表述 | 预期命中 | 检查用途 |
| --- | --- | --- |
| “这个 bug 为什么还没修好” | `systematic-debugging` | 校对 bug / 异常类表述是否会先走根因分析 |
| “这个测试怎么突然挂了” | `systematic-debugging` | 校对测试失败表述 |
| “帮我设计一下这个功能” | `brainstorming` | 校对设计前置触发 |
| “这个功能需求还没完全想清楚，先一起收敛一下” | `brainstorming` | 校对需求未确认场景 |
| “设计已经定了，给我拆计划” | `writing-plans` | 校对 spec 已存在时的计划触发 |
| “这个改动要跨几个文件，先拆一下执行步骤” | `writing-plans` | 校对多步骤多文件计划触发 |
| “这个任务可以收尾了吗” | `verification-before-completion` | 校对完成前验证触发 |
| “准备提交前帮我确认一下还有没有缺口” | `verification-before-completion` | 校对提交判断前验证触发 |
| “这个任务很复杂，直接用 vibe 跑” | `vibe` | 校对显式提到 vibe 的场景 |
| “这个要跨轮推进，而且后面还要冻结计划” | `vibe` | 校对复杂长链路场景 |
```

- [ ] **Step 2: Add a short note under the table about expected usage**

Append this note after the table:

```md
这些样本用于人工回归，不代表唯一有效说法；如果真实对话里经常出现新的高频表述，应优先补进这里再做校对。
```

- [ ] **Step 3: Verify the sample table now contains 10 rows**

Run: `rg -n '^\| “' "/home/zazaki/.config/opencode/references/ai/trigger-phrases.md"`
Expected: exactly 10 sample rows are found.

### Task 3: Add A Result-Recording Format For Trigger Checks

**Files:**
- Modify: `AI_GUIDE.md`
- Modify: `rules/ai/recording-rules.md`

- [ ] **Step 1: Add a trigger-check result format to `AI_GUIDE.md`**

Append this section:

```md
### Trigger Check Result Format

- 样本表述：
- 预期命中：
- 实际判断：命中 / 部分命中 / 未命中
- 如果未命中：应该调整 `AGENTS.md`、skill description、还是 `trigger-phrases.md`
```

- [ ] **Step 2: Add one short note to `rules/ai/recording-rules.md` about where trigger-check results belong**

Append this bullet under `### 快速判断`:

```md
- trigger-check 的回归结果：主落点写 `AI_GUIDE.md`，不写 `DECISIONS.md`
```

- [ ] **Step 3: Add a Phase 5 anchor to `AI_GUIDE.md`**

Append this section:

```md
### 2026-05-09 - Governance Phase 5 manual trigger-check enabled

- 已建立 `workflows/ai/trigger-check.md`
- `references/ai/trigger-phrases.md` 已扩展成 10 条人工回归样本
- trigger-check 结果默认记入 `AI_GUIDE.md`
```

- [ ] **Step 4: Verify the trigger-check result format and recording note exist**

Run: `rg -n "Trigger Check Result Format|trigger-check 的回归结果|manual trigger-check enabled" "/home/zazaki/.config/opencode/AI_GUIDE.md" "/home/zazaki/.config/opencode/rules/ai/recording-rules.md"`
Expected: all trigger-check recording phrases are present.

### Task 4: Validate Phase 5 Outputs

**Files:**
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` only if a clear mismatch remains after implementation

- [ ] **Step 1: Check for unresolved markers in Phase 5 touched files**

Run: `rg -n "TODO|TBD|FILL" "/home/zazaki/.config/opencode/workflows/ai/trigger-check.md" "/home/zazaki/.config/opencode/references/ai/trigger-phrases.md" "/home/zazaki/.config/opencode/AI_GUIDE.md" "/home/zazaki/.config/opencode/rules/ai/recording-rules.md" "/home/zazaki/.config/opencode/docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md"`
Expected: no matches.

- [ ] **Step 2: Check that the trigger sample count and workflow phrases match the plan**

Run: `rg -n '^\| “' "/home/zazaki/.config/opencode/references/ai/trigger-phrases.md" && rg -n "命中 / 部分命中 / 未命中|不要为了通过单条样本而把触发规则写得过宽|Trigger Check Result Format" "/home/zazaki/.config/opencode/workflows/ai/trigger-check.md" "/home/zazaki/.config/opencode/AI_GUIDE.md"`
Expected: 10 sample rows are present and the trigger-check phrasing exists.

- [ ] **Step 3: Record validation outcome in the final summary**

Include in final report:

```text
Validation run:
- phase 5 unresolved marker scan: pass/fail
- trigger-check workflow check: pass/fail
- trigger sample count check: pass/fail
- trigger result recording check: pass/fail
```

- [ ] **Step 4: Commit only if this directory becomes a git repository before execution time**

```bash
git add workflows/ai/trigger-check.md references/ai/trigger-phrases.md AI_GUIDE.md rules/ai/recording-rules.md docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md docs/superpowers/plans/2026-05-09-opencode-ai-governance-phase-5.md
git commit -m "docs: add manual AI trigger check flow"
```

If the directory is still not a git repository, skip commit and state that commit was not possible in the execution summary.
