---
name: using-superpowers
description: Use when starting a conversation or a new task and you need to determine which skill must be invoked before responding or acting
---

<SUBAGENT-STOP>
If you were dispatched as a subagent, skip this skill.
</SUBAGENT-STOP>

# Using Skills

## Core Rule

Before any response or action, check whether a skill applies.

- If there is even a small chance a skill applies, invoke it first.
- If multiple skills apply, use process skills before implementation skills.
- If the invoked skill turns out not to apply, stop using it and continue normally.

User instructions still override skill instructions.

## Priority

1. User instructions in chat or local repo rules
2. Relevant skills
3. Default system behavior

Do not skip a skill check because the task looks simple, you want more context first, or you think you already remember the skill.

## Typical Order

- New feature or behavior change: `brainstorming` first
- Bug or unexpected failure: `systematic-debugging` first
- Configuring OpenCode itself: `customize-opencode`
- Before completion claims: `verification-before-completion`

## Red Flags

- "This is just a quick question"
- "I'll inspect the repo first"
- "I'll do one thing before checking"
- "I already know the skill"

All of these mean: stop and check for a skill first.

## Tool Note

Use the platform's skill-loading mechanism, not direct file reads of skill content.

## Bottom Line

If a skill might help, load it before acting.
