---
name: context-handoff
description: Manage externalized project context, task state, decision records, and session handoffs for repositories that use files such as `AI_GUIDE.md`, `CURRENT_TASK.md`, `DECISIONS.md`, `handoff/`, or prompt templates. Use when starting a new task, refreshing current task status, recording a reusable technical decision, generating a compact handoff, or bootstrapping this file layout in a repo.
---

# Context Handoff

## Overview

Keep durable facts out of chat history. Read the minimum state files needed, update the correct authority file, and generate compact prompts or handoffs instead of replaying whole conversations.

## Workflow

### 1. Classify the request

Map the user request to one of these operations:

- Start task: create or refresh `CURRENT_TASK.md`, then produce a launch prompt.
- Update task: revise `CURRENT_TASK.md` after goals, scope, validation, or next steps change.
- Record decision: append a reusable conclusion to `DECISIONS.md`.
- Close session: produce a compact handoff or closeout note and update audit state when required.
- Bootstrap layout: initialize missing task-context files from this skill's assets.

### 2. Read the minimum context

- Always read repo-local rules first, especially `AGENTS.md` when present.
- Read `AI_GUIDE.md` summary and latest anchor only when the repo uses it for cross-session audit.
- Read `CURRENT_TASK.md` when the request concerns ongoing task state.
- Read `DECISIONS.md` only when reusable rationale or prior choices matter.
- Read [references/file-roles.md](references/file-roles.md) when you need a reminder of which file owns which kind of state.
- Read [references/quick-prompts.md](references/quick-prompts.md) when you need the shortest explicit `$context-handoff` prompts for common actions.

### 3. Write to one authority only

- Put current-task scope, status, validation target, and next steps in `CURRENT_TASK.md`.
- Put durable rationale and chosen tradeoffs in `DECISIONS.md`.
- Put project-level audit trail in `AI_GUIDE.md` only if the repo already uses it or the local rules require it.
- Put session handoff text in `handoff/` or the current response, not inside `CURRENT_TASK.md`.
- Avoid copying the same fact into multiple files unless one file explicitly summarizes another.

### 4. Use assets when bootstrapping or drafting

Use these assets as starting points, then adapt them to the repository:

- [assets/CURRENT_TASK.template.md](assets/CURRENT_TASK.template.md) for initializing or resetting task state.
- [assets/DECISIONS.template.md](assets/DECISIONS.template.md) for initializing a reusable decision log.
- [assets/NEW_TASK_START.template.md](assets/NEW_TASK_START.template.md) for a new-session launch prompt.
- [assets/SESSION_CLOSEOUT.template.md](assets/SESSION_CLOSEOUT.template.md) for a compact end-of-session handoff.

After copying an asset into the repo, treat the repo-local copy as the new source of truth.

## Operating Rules

- Prefer minimal context injection over replaying long chat history.
- Preserve timestamps, anchors, and audit structure when editing `AI_GUIDE.md`.
- Overwrite stale task content in `CURRENT_TASK.md`; do not keep old tasks in the same file.
- Record decisions only when they will likely matter again.
- Keep handoffs short: objective, done, not done, blockers, related files, verification, risks.
- If the repo already defines stricter rules in `AGENTS.md`, follow those rules over this skill.
