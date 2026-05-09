# OpenCode AI Governance Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立最小可用的 AI 治理骨架，把任务路由、任务闭环、记录边界和基础 workflow 从 `AGENTS.md` 中抽离到独立文件。

**Architecture:** 本阶段只做治理层落地，不重写现有 skills，不调整 MCP 配置，不做模板化。通过新增 `rules/ai/`、`workflows/ai/`、`references/ai/` 三类目录，形成薄壳入口加显式文件路由的结构，并只对 `AGENTS.md` 做最小补充而不是大改。

**Tech Stack:** Markdown 文档、OpenCode 配置目录结构、现有 skills 与 MCP 约定

---

### Task 1: Create Governance Directory Skeleton

**Files:**
- Create: `rules/ai/routing-rules.md`
- Create: `rules/ai/task-closure.md`
- Create: `rules/ai/recording-rules.md`
- Create: `rules/ai/verification-rules.md`
- Create: `workflows/ai/fix-bug.md`
- Create: `workflows/ai/review.md`
- Create: `workflows/ai/update-rules.md`
- Create: `references/ai/gotchas.md`
- Create: `references/ai/tool-differences.md`
- Create: `references/ai/anti-patterns.md`

- [ ] **Step 1: Verify the target directories do not already exist**

Run: `ls "/home/zazaki/.config/opencode"`
Expected: directory listing does not already contain populated `workflows/ai` or `references/ai`; `rules` may exist but `rules/ai` may be absent.

- [ ] **Step 2: Create the directory skeleton**

Run: `mkdir -p "/home/zazaki/.config/opencode/rules/ai" "/home/zazaki/.config/opencode/workflows/ai" "/home/zazaki/.config/opencode/references/ai"`
Expected: command exits successfully with no output.

- [ ] **Step 3: Create minimal initial content for `rules/ai/routing-rules.md`**

```md
## AI Routing Rules

### Purpose

Define the default file-reading path and task routing path for non-trivial AI work in this OpenCode environment.

### Always Read

1. `AGENTS.md`
2. `CURRENT_TASK.md` when it exists in the active project
3. `DECISIONS.md` when the task depends on prior technical decisions

### Common Tasks

- Fix bug: use `systematic-debugging` and then follow `workflows/ai/fix-bug.md`
- Implement feature: use `brainstorming`, then `writing-plans`, then follow `workflows/ai/implement-feature.md` when it exists
- Review work: follow `workflows/ai/review.md`
- Complex multi-file or cross-round work: prefer `vibe`
- Unlisted task: apply Always Read, then choose the closest workflow and explain the match

### Routing Checks

- Do not assume a prior task route still applies to a new task in the same session.
- Re-read the route when the task intent changes.
- If no workflow matches cleanly, say which workflow is being used as the closest fit.
```

- [ ] **Step 4: Create minimal initial content for `rules/ai/task-closure.md`**

```md
## Task Closure Rules

### Task Completion Definition

A non-trivial task is not complete until all of the following are true:

1. The main work is finished.
2. Relevant verification has been run.
3. A short AAR pass has been performed.
4. Any reusable lesson is recorded in the correct location.

### AAR Questions

1. Did this task reveal a new pitfall?
2. Did this task expose a missing rule?
3. Did this task reveal an outdated rule?
4. Did this task prove a verification step worth reusing?

### Narrow Skip Cases

The heavier closure path may be skipped only for:

- formatting-only changes
- comment-only changes
- dependency-version-only changes
- behavior-preserving refactors with no new lessons
```

- [ ] **Step 5: Create minimal initial content for `rules/ai/recording-rules.md`**

```md
## AI Recording Rules

### Recording Targets

- Current goal, status, next step: `CURRENT_TASK.md`
- Reusable technical decisions: `DECISIONS.md`
- Project-level audit notes and verification anchors: `AI_GUIDE.md`
- Session handoff summaries: `handoff/`
- Stable governance rules: `rules/ai/`
- High-cost, repeatable pitfalls: `references/ai/`
- Ordered task procedures: `workflows/ai/`

### Do Not Record Here

- Do not write raw session logs into `rules/ai/`.
- Do not write raw session logs into `references/ai/`.
- Do not use governance files as a replacement for git history.

### Recording Threshold

Record a new pitfall or rule only when at least two of the following are true:

1. It is likely to happen again.
2. Missing it would cost meaningful time or quality.
3. The lesson is not obvious from reading the code alone.
```

- [ ] **Step 6: Create minimal initial content for `rules/ai/verification-rules.md`**

```md
## AI Verification Rules

### Before Claiming Completion

For each non-trivial task:

1. Run the relevant verification command.
2. State exactly what was run.
3. State the result.
4. If the task is being judged commit-ready, run `repo-audit` first.

### Evidence Rule

Do not claim a task is complete, fixed, or passing without test, build, lint, or audit evidence that matches the task.
```

- [ ] **Step 7: Create minimal initial content for `workflows/ai/fix-bug.md`**

```md
## Fix Bug Workflow

1. Read `AGENTS.md` and `rules/ai/routing-rules.md`.
2. Use `systematic-debugging` before proposing a fix.
3. Inspect the relevant code and tests.
4. Make the smallest correct change.
5. Run task-relevant verification.
6. Apply `rules/ai/task-closure.md` before declaring completion.
```

- [ ] **Step 8: Create minimal initial content for `workflows/ai/review.md`**

```md
## Review Workflow

1. Read `AGENTS.md` and `rules/ai/routing-rules.md`.
2. Prioritize bugs, regressions, missing tests, and proof gaps.
3. Present findings first, ordered by severity.
4. State assumptions and residual risk after findings.
5. Do not lead with a summary when findings exist.
```

- [ ] **Step 9: Create minimal initial content for `workflows/ai/update-rules.md`**

```md
## Update Rules Workflow

1. Run the AAR questions from `rules/ai/task-closure.md`.
2. If all answers are no, stop.
3. If any answer is yes, decide whether the update belongs in:
   - `rules/ai/`
   - `references/ai/`
   - `CURRENT_TASK.md`
   - `DECISIONS.md`
   - `AI_GUIDE.md`
4. Prefer the lightest correct recording format.
5. Do not write session narrative into governance reference files.
```

- [ ] **Step 10: Create initial empty reference files with explicit scope**

```md
## AI Gotchas

Add only high-cost, repeatable pitfalls that are not obvious from code reading alone.
```

```md
## Tool Differences

Record only real, observed differences between harnesses, tools, or runtimes that affect execution quality.
```

```md
## AI Anti-Patterns

Record only real anti-patterns that have already caused drift, quality loss, or execution mistakes.
```

- [ ] **Step 11: Verify the files exist**

Run: `ls "/home/zazaki/.config/opencode/rules/ai" && ls "/home/zazaki/.config/opencode/workflows/ai" && ls "/home/zazaki/.config/opencode/references/ai"`
Expected: all ten files are listed.

### Task 2: Add Governance Routing Notes To AGENTS.md

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: Read the current `AGENTS.md` and locate the best insertion point near execution path or state rules**

Run: `rg -n "执行路径|状态文件与读写|Skills 自动触发|交付要求" "/home/zazaki/.config/opencode/AGENTS.md"`
Expected: matching section line numbers are shown.

- [ ] **Step 2: Insert a short governance routing note without rewriting the file**

```md
## AI Governance Routing

- 任务级路由细则见 `rules/ai/routing-rules.md`
- 任务闭环规则见 `rules/ai/task-closure.md`
- 记录位置规则见 `rules/ai/recording-rules.md`
- 通用验证规则见 `rules/ai/verification-rules.md`
- 具体任务流程见 `workflows/ai/`
- 高代价坑点与工具差异见 `references/ai/`
```

- [ ] **Step 3: Verify `AGENTS.md` still reads as a top-level shell rather than a detailed rule dump**

Run: `rg -n "AI Governance Routing|rules/ai|workflows/ai|references/ai" "/home/zazaki/.config/opencode/AGENTS.md"`
Expected: the new references appear once and do not duplicate the same ideas across multiple sections.

### Task 3: Create The Missing Feature Workflow Stub

**Files:**
- Create: `workflows/ai/implement-feature.md`
- Create: `workflows/ai/plan.md`

- [ ] **Step 1: Create `workflows/ai/implement-feature.md` to match the already-planned route**

```md
## Implement Feature Workflow

1. Use `brainstorming` before implementation-oriented design work.
2. Write or confirm a design artifact.
3. Use `writing-plans` before implementation when the work is multi-step.
4. Prefer the smallest correct implementation.
5. Run relevant verification.
6. Apply `rules/ai/task-closure.md` before declaring completion.
```

- [ ] **Step 2: Create `workflows/ai/plan.md` as the planning path reference**

```md
## Plan Workflow

1. Clarify goal, constraints, and success criteria.
2. Produce or update the design artifact.
3. Turn approved design into an implementation plan.
4. Keep planning output in `docs/superpowers/specs/` and `docs/superpowers/plans/`.
```

- [ ] **Step 3: Verify the routing file no longer references a missing workflow**

Run: `rg -n "implement-feature.md|plan.md" "/home/zazaki/.config/opencode/rules/ai" "/home/zazaki/.config/opencode/workflows/ai"`
Expected: both workflow names are found in existing files.

### Task 4: Validate The Governance Skeleton

**Files:**
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` only if a clear mismatch is discovered

- [ ] **Step 1: Check that every designed governance file now exists**

Run: `test -f "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" && test -f "/home/zazaki/.config/opencode/rules/ai/task-closure.md" && test -f "/home/zazaki/.config/opencode/rules/ai/recording-rules.md" && test -f "/home/zazaki/.config/opencode/rules/ai/verification-rules.md" && test -f "/home/zazaki/.config/opencode/workflows/ai/fix-bug.md" && test -f "/home/zazaki/.config/opencode/workflows/ai/review.md" && test -f "/home/zazaki/.config/opencode/workflows/ai/update-rules.md" && test -f "/home/zazaki/.config/opencode/workflows/ai/implement-feature.md" && test -f "/home/zazaki/.config/opencode/workflows/ai/plan.md" && test -f "/home/zazaki/.config/opencode/references/ai/gotchas.md" && test -f "/home/zazaki/.config/opencode/references/ai/tool-differences.md" && test -f "/home/zazaki/.config/opencode/references/ai/anti-patterns.md"`
Expected: command exits with status 0.

- [ ] **Step 2: Check that the design and implementation files agree on the created structure**

Run: `rg -n "rules/ai|workflows/ai|references/ai" "/home/zazaki/.config/opencode/docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md"`
Expected: the design references the same structure created by the implementation tasks.

- [ ] **Step 3: Check for unresolved marker failures in the new governance files**

Run: `rg -n "TODO|TBD|FILL" "/home/zazaki/.config/opencode/rules/ai" "/home/zazaki/.config/opencode/workflows/ai" "/home/zazaki/.config/opencode/references/ai"`
Expected: no matches.

- [ ] **Step 4: Record validation outcome in the final summary**

Include in final report:

```text
Validation run:
- governance files existence check: pass/fail
- unresolved marker scan: pass/fail
- AGENTS routing insertion check: pass/fail
```

- [ ] **Step 5: Commit if and only if this directory becomes a git repository before execution time**

```bash
git add AGENTS.md rules/ai workflows/ai references/ai docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md docs/superpowers/plans/2026-05-09-opencode-ai-governance-phase-1.md
git commit -m "docs: add AI governance skeleton and routing rules"
```

If the directory is still not a git repository, skip commit and state that commit was not possible in the execution summary.
