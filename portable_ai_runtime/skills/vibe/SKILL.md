---
name: vibe
description: Use when the task spans multiple files, needs frozen requirements or plans, requires governed phased execution, or the user explicitly asks to use `vibe`
---

# Vibe Governed Runtime

`vibe` is the governed runtime for non-trivial work that needs explicit requirements, a frozen plan, phased execution, verification, and cleanup.

`/vibe`, `$vibe`, and agent-invoked `vibe` mean the same governed entry.

## When To Use

Use `vibe` when the task:

- spans multiple files
- needs requirement clarification before coding
- needs a frozen requirement or plan surface
- needs governed phased execution and explicit verification
- needs stronger cleanup and delivery discipline

Do not use `vibe` for:

- casual Q and A
- explanation-only requests
- tiny edits where governed overhead is unnecessary

## Runtime Contract

`vibe` always keeps one governed runtime authority. It does not create a second router, second requirement surface, or second plan surface.

The runtime always follows these six stages:

1. `skeleton_check`
2. `deep_interview`
3. `requirement_doc`
4. `xl_plan`
5. `plan_execute`
6. `phase_cleanup`

Stages may become lighter for smaller work, but they are not skipped as a policy shortcut.

## Runtime Mode

Supported governed mode:

- `interactive_governed`
  每个涉及用户确认的阶段必须执行以下 STOP 检查：

  - [ ] requirement_doc 产出后：用户是否已审阅并批准需求文档？未批准 → STOP，不进入 xl_plan
  - [ ] xl_plan 产出后：用户是否已审阅并批准执行计划？未批准 → STOP，不进入 plan_execute
  - [ ] 任何阶段中发现高价值决策点：是否已启动 grill-me 访谈（`rules/ai/grill-me-protocol.md`）逐条确认？

  以上任一 STOP 触发时，不得越过当前阶段继续执行。

## Root And Child Boundaries

`vibe` may run as:

- `root_governed`: owns canonical requirement and plan truth, and may issue final completion claims
- `child_governed`: inherits frozen context, performs bounded execution, and emits local receipts only

Child-governed lanes must not create a second canonical requirement or plan surface, and must not publish full-task completion claims.

If subagents are spawned, their prompts must end with `$vibe`.

## Internal Grades

`M`, `L`, and `XL` are internal execution grades, not user-facing entry choices.

- `M`: narrow, single-agent work
- `L`: serial governed execution
- `XL`: wave-sequential execution with bounded parallelism only for independent units

The runtime selects the grade after `deep_interview` and before `plan_execute`.

## Quality Rules

- No success claims without evidence
- Requirement and plan surfaces must stay traceable
- Verification must happen before completion wording
- Cleanup is part of completion, not an afterthought

## Protocol Map

Read detailed contracts on demand:

- `protocols/runtime.md`
- `protocols/think.md`
- `protocols/do.md`
- `protocols/review.md`
- `protocols/team.md`
- `protocols/retro.md`

## Outputs

Governed runs should leave behind the requirement, the plan, phase receipts, and cleanup receipts under the runtime output structure described by the protocols.

## Boundaries

- canonical router owns route selection
- `vibe` owns governed runtime authority
- specialist help is allowed only as bounded assistance, not a second runtime
- host adapters may shape implementation details, but must not fork runtime truth

## Maintenance

- Runtime family: governed-runtime-first
- Version: 3.0.0
- Updated: 2026-04-07
- Canonical router: `scripts/router/resolve-pack-route.ps1`
- Primary contract metadata: `config/runtime-contract.json`

本文件中的用户确认点遵循 `rules/ai/grill-me-protocol.md`：一次一问、每问带推荐、深度优先遍历。
