# Quick Prompts

Use these short prompts when you want to trigger `$context-handoff` without writing a longer brief.

## 1. Start or refresh a task

```text
Use $context-handoff to refresh CURRENT_TASK.md for this repo and draft a new task start prompt.
```

## 2. Record a reusable decision

```text
Use $context-handoff to record today's decision in DECISIONS.md and summarize its impact.
```

## 3. Close the session

```text
Use $context-handoff to generate a session closeout handoff from CURRENT_TASK.md and recent work.
```

## 4. Standard old-session closeout

```text
Use $context-handoff to:
1. refresh CURRENT_TASK.md to match the actual latest state,
2. record any reusable decision in DECISIONS.md if needed,
3. generate a session closeout handoff from CURRENT_TASK.md and recent work,
4. update AI_GUIDE.md if this repo uses it.

If anything is unclear, ask only for the missing facts.
```

## 5. Standard new-session start

```text
继续处理这个 repo 的当前任务。

Use $context-handoff to:
1. read AGENTS.md,
2. read AI_GUIDE.md 的固定概要区和最新 READ_ANCHOR 之后的增量内容，
3. read CURRENT_TASK.md，
4. read relevant entries in DECISIONS.md if needed，
5. continue from the current task state，
6. ask only if a critical fact is missing.

交付时请说明：
- 改了什么
- 为什么这样改
- 做了哪些验证
- 剩余风险或未覆盖项
```

## 6. Standard new-session start for a new task

```text
这是一个新任务，不延续上一个任务。

Use $context-handoff to:
1. refresh CURRENT_TASK.md for a new task in this repo,
2. read AGENTS.md,
3. read AI_GUIDE.md 的固定概要区和最新 READ_ANCHOR 之后的增量内容，
4. read relevant entries in DECISIONS.md if needed，
5. continue with the new task below.

新任务目标：
- [要完成什么]

范围：
- [允许改什么]
- [不改什么]

验收标准：
- [标准 1]
- [标准 2]

约束：
- [兼容性 / 安全 / 性能 / 成本约束]

交付时请说明：
- 改了什么
- 为什么这样改
- 做了哪些验证
- 剩余风险或未覆盖项
```

## Notes

- Replace “this repo” with a specific path if the working directory is ambiguous.
- If the repo requires stronger governed execution, add `$vibe` to the surrounding request.
- If you already know the exact files in scope, add them after the prompt instead of rewriting the whole history.
