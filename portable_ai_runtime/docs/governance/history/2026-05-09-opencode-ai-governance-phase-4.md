# OpenCode AI Governance Phase 4 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 提高关键 skills 的自动命中率，并把 `AGENTS.md` 与 skill 自身描述的触发边界收紧到一致状态。

**Architecture:** 本阶段不新增治理目录，也不引入自动化脚本系统，而是先做“文字级触发优化”。通过同步 `AGENTS.md` 的自动触发语句、关键 skill 的 frontmatter `description` 和治理层路由规则，让常见任务表述更稳定地命中正确 skill 或执行路径。

**Tech Stack:** Markdown 文档、现有 skill frontmatter、`AGENTS.md`、`rules/ai/routing-rules.md`

---

### Task 1: Tighten AGENTS.md Skill Auto-Trigger Wording

**Files:**
- Modify: `AGENTS.md`
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md`

- [ ] **Step 1: Read the current AGENTS skill auto-trigger section and routing rules**

Run: `rg -n "Skills 自动触发|brainstorming|writing-plans|systematic-debugging|verification-before-completion|vibe" "/home/zazaki/.config/opencode/AGENTS.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md"`
Expected: the current trigger wording is shown from both files.

- [ ] **Step 2: Replace the AGENTS skill auto-trigger bullets for the five key skills with tighter wording**

Update the `### Skills 自动触发` bullets in `AGENTS.md` to the following exact wording:

```md
- **vibe**：任务涉及多文件修改、跨轮跟踪、冻结 requirement/plan、较强验证闭环，或用户明确提到 `vibe` 时自动触发
- **systematic-debugging**：出现 bug、测试失败、构建失败、意外行为，且尚未完成根因分析时自动触发
- **brainstorming**：新增功能、行为修改、方案探索、需求设计，且尚未完成设计确认时自动触发
- **writing-plans**：已经有设计/spec，且实现步骤达到 3 步及以上、涉及多文件修改、或需要跨轮执行时自动触发
- **verification-before-completion**：准备声称任务完成、问题已修复、结果已通过、或准备进入提交判断前自动触发
```

- [ ] **Step 3: Sync the design spec so it matches the tightened trigger wording**

Update `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` so that its skill/routing sections reflect the same trigger language for:

- `vibe`
- `systematic-debugging`
- `brainstorming`
- `writing-plans`
- `verification-before-completion`

- [ ] **Step 4: Add one short sentence clarifying that routing-rules decides path, AGENTS decides top-level auto-trigger intent**

Append this sentence near the skill/routing relationship in the design spec:

```md
`AGENTS.md` 负责顶层自动触发意图，`rules/ai/routing-rules.md` 负责任务路径细化，两者必须保持一致但不重复维护全部细节。
```

- [ ] **Step 5: Verify the new AGENTS trigger phrases exist**

Run: `rg -n "尚未完成根因分析|尚未完成设计确认|实现步骤达到 3 步及以上|准备声称任务完成|较强验证闭环" "/home/zazaki/.config/opencode/AGENTS.md"`
Expected: all tightened trigger phrases are present.

### Task 2: Tighten Key Skill Frontmatter Descriptions

**Files:**
- Modify: `skills/brainstorming/SKILL.md`
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `skills/systematic-debugging/SKILL.md`
- Modify: `skills/verification-before-completion/SKILL.md`

- [ ] **Step 1: Update `brainstorming` frontmatter description**

Replace the `description` line with:

```md
description: "Use before adding a new feature, changing behavior, or exploring a solution when requirements or design are not yet confirmed"
```

- [ ] **Step 2: Update `writing-plans` frontmatter description**

Replace the `description` line with:

```md
description: "Use after a design or spec exists and before implementation when the work is multi-step, multi-file, or likely to continue across turns"
```

- [ ] **Step 3: Update `systematic-debugging` frontmatter description**

Replace the `description` line with:

```md
description: "Use when a bug, test failure, build failure, or unexpected behavior appears and root cause has not yet been established"
```

- [ ] **Step 4: Update `verification-before-completion` frontmatter description**

Replace the `description` line with:

```md
description: "Use before claiming a task is complete, fixed, or passing, and before making any commit-readiness judgment"
```

- [ ] **Step 5: Verify the four new frontmatter descriptions are present**

Run: `rg -n '^description:' "/home/zazaki/.config/opencode/skills/brainstorming/SKILL.md" "/home/zazaki/.config/opencode/skills/writing-plans/SKILL.md" "/home/zazaki/.config/opencode/skills/systematic-debugging/SKILL.md" "/home/zazaki/.config/opencode/skills/verification-before-completion/SKILL.md"`
Expected: each file shows exactly one updated description line.

### Task 3: Add A Minimal Trigger-Mapping Reference

**Files:**
- Create: `references/ai/trigger-phrases.md`
- Modify: `rules/ai/routing-rules.md`
- Modify: `AI_GUIDE.md`

- [ ] **Step 1: Create `references/ai/trigger-phrases.md` with a minimal mapping table**

Create this exact content:

```md
## Trigger Phrases

此文件记录常见任务表述与推荐命中路径，用于人工校对 trigger wording，不作为唯一权威源。

| 常见表述 | 推荐命中 |
| --- | --- |
| “这个 bug 为什么还没修好” | `systematic-debugging` |
| “帮我设计一下这个功能” | `brainstorming` |
| “设计已经定了，给我拆计划” | `writing-plans` |
| “这个任务可以收尾了吗” | `verification-before-completion` |
| “这个任务很复杂，直接用 vibe 跑” | `vibe` |
```

- [ ] **Step 2: Add one short note to `rules/ai/routing-rules.md` that this file may be used for manual trigger calibration only**

Append this bullet under `### 优先级`:

```md
- `references/ai/trigger-phrases.md` 仅用于人工校对常见表述与推荐路径，不替代本文件的正式路由规则。
```

- [ ] **Step 3: Add a Phase 4 anchor to `AI_GUIDE.md`**

Append this section:

```md
### 2026-05-09 - Governance Phase 4 trigger wording tightened

- 已收紧关键 skill 的 frontmatter `description`
- 已收紧 `AGENTS.md` 的自动触发语句
- 已增加最小 trigger phrase 对照表，用于后续人工校对命中率
```

- [ ] **Step 4: Verify the trigger-phrases reference and its routing note exist**

Run: `rg -n "Trigger Phrases|常见表述|人工校对|不替代本文件的正式路由规则|Governance Phase 4 trigger wording tightened" "/home/zazaki/.config/opencode/references/ai/trigger-phrases.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/AI_GUIDE.md"`
Expected: all trigger-reference phrases are present.

### Task 4: Validate Phase 4 Outputs

**Files:**
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` only if a clear mismatch remains after implementation

- [ ] **Step 1: Check for unresolved markers in Phase 4 touched files**

Run: `rg -n "TODO|TBD|FILL" "/home/zazaki/.config/opencode/AGENTS.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/references/ai/trigger-phrases.md" "/home/zazaki/.config/opencode/AI_GUIDE.md" "/home/zazaki/.config/opencode/docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md"`
Expected: no matches.

- [ ] **Step 2: Check that AGENTS, skill descriptions, and routing/spec language align**

Run: `rg -n "尚未完成根因分析|尚未完成设计确认|实现步骤达到 3 步及以上|before implementation when the work is multi-step|root cause has not yet been established|before claiming a task is complete|较强验证闭环|人工校对" "/home/zazaki/.config/opencode/AGENTS.md" "/home/zazaki/.config/opencode/skills/brainstorming/SKILL.md" "/home/zazaki/.config/opencode/skills/writing-plans/SKILL.md" "/home/zazaki/.config/opencode/skills/systematic-debugging/SKILL.md" "/home/zazaki/.config/opencode/skills/verification-before-completion/SKILL.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/references/ai/trigger-phrases.md" "/home/zazaki/.config/opencode/docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md"`
Expected: the tightened trigger wording is visible across the intended files.

- [ ] **Step 3: Record validation outcome in the final summary**

Include in final report:

```text
Validation run:
- phase 4 unresolved marker scan: pass/fail
- AGENTS trigger wording check: pass/fail
- skill description sync check: pass/fail
- trigger-reference alignment check: pass/fail
```

- [ ] **Step 4: Commit only if this directory becomes a git repository before execution time**

```bash
git add AGENTS.md rules/ai/routing-rules.md skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md skills/systematic-debugging/SKILL.md skills/verification-before-completion/SKILL.md references/ai/trigger-phrases.md AI_GUIDE.md docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md docs/superpowers/plans/2026-05-09-opencode-ai-governance-phase-4.md
git commit -m "docs: tighten AI skill trigger wording"
```

If the directory is still not a git repository, skip commit and state that commit was not possible in the execution summary.
