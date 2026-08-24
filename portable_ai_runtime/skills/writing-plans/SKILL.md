---
name: writing-plans
description: "Use after a design or spec exists and before implementation when the work is multi-step, multi-file, or likely to continue across turns"
---

# Writing Plans

Write comprehensive implementation plans assuming the engineer has zero context for our codebase. Break work into bite-sized TDD tasks with exact file paths, complete code, and expected outputs. DRY. YAGNI. TDD. Frequent commits.

## Core Rules

1. **Each step is one action (2-5 minutes)** — write test, run test, implement, run test, commit.
2. **Every step contains complete content** — no TBD, no "similar to Task N", no hand-wavy descriptions.
3. **Exact paths and commands** — file paths are always exact; every command has expected output.
4. **Plan header is mandatory** — Goal, Architecture, Tech Stack, and agentic workers instruction.
5. **Self-review before handoff** — spec coverage, placeholder scan, type consistency check.

检验：计划中的每一步，工程师是否可以完全按步骤操作而不需要额外猜测？

## When To Use

- After brainstorming produces a spec, before implementation starts
- Work spans 3+ files or requires sequential task ordering
- The plan needs to be executable across sessions or by different agents
- TDD workflow where each test-implement-commit cycle needs explicit documentation

**前置条件门禁** — 进入计划编写前：

- [ ] 是否已有经过用户批准的设计方案/spec？
- [ ] 所有结构性决策（文件边界、架构分叉、依赖选择）是否已确认？

**任意一项未通过 → STOP。返回 brainstorming 先产出设计/spec。遵循 `rules/ai/grill-me-protocol.md` 确认结构性决策后再进入本 skill。**

## Common Tasks

| Task | Route |
|------|-------|
| Write a plan | Follow process in `workflows/ai/plan-writing.md` |
| Check plan constraints | See `rules/ai/plan-writing-rules.md` |
| Decide file structure | Use `rules/ai/grill-me-protocol.md` for user decisions |
| Execute a plan | Use `subagent-driven-development` (recommended) or `executing-plans` |

## Known Gotchas

- Plans saved to `docs/superpowers/plans/` by default — user preferences override this.
- If spec covers multiple independent subsystems, suggest splitting into separate plans before writing.
- Do not write plans for single-file, single-step changes or simple bug fixes — use `fix-and-review` instead.
- 详见 `rules/ai/plan-writing-rules.md` 中"禁止占位符规则"的完整列表。

## Protocol

规则层在 `rules/ai/plan-writing-rules.md`，工作流在 `workflows/ai/plan-writing.md`。本文件是用户入口；规则与工作流是可复用的行为与过程规范。
