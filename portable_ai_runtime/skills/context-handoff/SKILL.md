---
name: context-handoff
description: Use when starting a new task, refreshing `CURRENT_TASK.md`, recording a reusable decision, generating a handoff, or bootstrapping task-state files such as `AI_GUIDE.md`, `CURRENT_TASK.md`, and `DECISIONS.md`
---

# Context Handoff

Keep durable context in files, not in chat history.

## Use Cases

- Start or reset a task: update `CURRENT_TASK.md`
- Record a reusable conclusion: append to `DECISIONS.md`
- Add a project-level audit anchor: update `AI_GUIDE.md`
- Produce a handoff or closeout summary
- Bootstrap missing task-state files from this skill's assets

## Read Minimum Context

- Read repo-local rules first, especially `AGENTS.md`
- Read `CURRENT_TASK.md` for current task state
- Read `DECISIONS.md` only when prior rationale matters
- Read `AI_GUIDE.md` only when project-level audit anchors matter

## One Authority Per Fact

- `CURRENT_TASK.md`: current goal, scope, status, next steps
- `DECISIONS.md`: durable technical decisions and tradeoffs
- `AI_GUIDE.md`: project-level audit anchors and reusable verification notes
- `handoff/` or current response: session handoff text

Do not spread the same conclusion across multiple files unless one file is explicitly summarizing another.

## Operating Rules

- Overwrite stale task content in `CURRENT_TASK.md`
- Prefer short updates over replaying chat history
- Keep handoffs compact: objective, done, not done, blockers, related files, verification, risks
- Use `/new-session` only when the goal is a paste-ready new-session prompt

## Assets

Use these when bootstrapping or resetting state:

- `assets/CURRENT_TASK.template.md`
- `assets/DECISIONS.template.md`
- `assets/NEW_TASK_START.template.md`
- `assets/SESSION_CLOSEOUT.template.md`
