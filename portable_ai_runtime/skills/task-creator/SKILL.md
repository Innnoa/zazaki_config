---
name: task-creator
description: Use when the user wants to create a new task for the goal-runner loop — whether in English ("create task", "add task", "new task", "todo task") or in Chinese ("创建任务", "新增任务", "添加待办", "新建任务"). This skill transforms a raw requirement into a structured TASK.md inside a dated task folder under `tasks/`.
---

# Task Creator

Turn a raw requirement into a structured task package that `goal-runner.py` can pick up and execute.

## When To Use

- User describes work they want the loop to handle automatically
- User wants to batch-add multiple tasks
- User needs AI to refine a vague requirement into concrete acceptance criteria

Do not use for:
- Tasks that should be executed immediately by the current agent
- Tasks that don't need loop execution

## What It Does

1. Reads the user's requirement
2. Refines it: goal, concrete acceptance criteria, known context, constraints
3. Creates a folder: `tasks/YYYY-MM-DD_{slug}_pending/`
4. Writes `TASK.md` with the structured content
5. Writes `COMPLETION.md` as an empty template
6. Reports the created path

## Folder Location

All task folders live under `~/Projects/tasks/`. The folder structure is:

```
~/Projects/tasks/2026-07-01_修复搜索超时_pending/
```

## Folder Naming

- Date: today's date in `YYYY-MM-DD`
- Slug: Chinese or English, short and descriptive, use `_` as separator
- Status suffix: always `_pending` when created (goal-runner renames to `_done` on completion)

## TASK.md Structure

Use the template in `assets/TASK.template.md`. Required sections:

- `## 目标` — one sentence describing the desired outcome
- `## 工作目录` — the absolute path where this task should be executed. Set to the current OpenCode working directory at creation time, unless the user explicitly provides a different directory.
- `## 验收标准` — bullet list of measurable completion conditions
- `## 上下文` — relevant background, related issues, known constraints (can be empty if none)
- `## 约束` — hard limits: must not break X, must stay within Y boundary

## COMPLETION.md Structure

Write as empty template from `assets/COMPLETION.template.md`. The goal-runner agent fills it after task completion.

## AAR.md Structure

Write as empty template from `assets/AAR.template.md`. After the goal-runner agent completes execution, it should fill AAR.md with structured experience entries (type, content, suggested destination, status=new). Use `/aar-collect` later to consolidate these into formal governance files.

## Operating Rules

- If the user's requirement is vague: launch grill-me interview (`rules/ai/grill-me-protocol.md`), clarify layer by layer until the task boundary is clear:

  - [ ] Is the task goal clear and unambiguous?
  - [ ] Is the task scope boundary confirmed?
  - [ ] Are all "I assume the user wants X" assumptions eliminated?

  **Any item NOT checked → STOP. Do NOT create TASK.md. Continue grill-me interview until all pass.**
- Prefer concrete acceptance criteria over vague ones
- Always include the `_pending` suffix in the folder name
- Do NOT put code or project files in the task folder — only TASK.md and COMPLETION.md
- Tasks are processed sequentially by goal-runner in alphabetical order
