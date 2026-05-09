# File Roles

Use this reference when deciding which context file to read or update.

## Ownership Map

| File | Owns | Read when | Update when |
| --- | --- | --- | --- |
| `AI_GUIDE.md` | Project-level audit, recent summary, anchors, cross-session execution history | You need prior audit context or local rules require audit updates | A substantial session changes repo state and the repo already uses AI audit |
| `CURRENT_TASK.md` | Current task goal, scope, acceptance criteria, related files, current status, next step | You are continuing or modifying the active task | Goal, scope, acceptance criteria, status, blockers, or next steps change |
| `DECISIONS.md` | Reusable decisions with rationale and impact | You need to understand why a prior choice was made | A decision is stable enough to matter in later sessions |
| `handoff/` or closeout note | Compact transition summary for the next session | You are resuming from a prior handoff | You are ending a session and need to transfer context |
| Launch / closeout prompt templates | Reusable prompt shells for opening or closing a session | You need a fresh prompt quickly | The template itself needs improvement |

## Anti-patterns

- Do not store complete chat transcripts as long-term context.
- Do not keep old task histories in `CURRENT_TASK.md`.
- Do not paste large diffs or logs into handoff text.
- Do not write the same fact in three places unless one copy is explicitly a summary.
- Do not turn `DECISIONS.md` into a generic TODO list.
