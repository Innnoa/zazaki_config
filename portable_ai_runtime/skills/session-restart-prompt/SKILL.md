---
name: session-restart-prompt
description: Use when the user asks to summarize the current session or current task into a paste-ready prompt for a new session, handoff, continue-later, resume-later, or reopen-task request.
---

# Session Restart Prompt

## Overview

Generate one paste-ready prompt for a fresh session. Prefer durable context files over replaying the whole chat.

## Read Order

1. Read `AGENTS.md` if present.
2. Read `CURRENT_TASK.md` if present.
3. Read only the `DECISIONS.md` entries relevant to this task.
4. Read only the `AI_GUIDE.md` anchors relevant to this task.
5. Read at most 1 to 3 directly related files when the task state or user request identifies them clearly.
6. Do not guess file paths, progress, or verification.

## Output Contract

- Output exactly one paste-ready prompt.
- Do not prepend analysis, rationale, or a summary unless the user explicitly asks.
- Keep it concise and action-oriented.
- If some fact is unknown, mark it as `[待确认]` instead of guessing.
- If the current task state looks stale or inconsistent, say so briefly inside the prompt.

## Fixed Template

```text
继续处理 `[仓库或目录]` 下的任务。

先按治理入口重新路由，并阅读：
1. AGENTS.md
2. rules/ai/routing-rules.md（含会话纪律）
3. CURRENT_TASK.md
4. DECISIONS.md 中与本任务相关的条目
5. AI_GUIDE.md 中与本任务相关的锚点
6. [直接相关文件 1]
7. [直接相关文件 2]
8. [直接相关文件 3]

本次目标：
- [一句话目标]

当前状态：
- [当前进展]
- [已经到哪一步]

已完成：
- [完成项 1]
- [完成项 2]

剩余工作：
- [待办 1]
- [待办 2]

范围与约束：
- 允许修改：[文件 / 模块范围]
- 明确不改：[非范围内容]
- 必须遵守：[治理 / 安全 / 实现约束]

验证：
- 已完成：[已执行的命令或检查]
- 仍需补做：[下一会话应执行的验证]

风险与未知：
- [风险或未确认点 1]
- [风险或未确认点 2]

交付时请说明：
- 改了什么
- 为什么这样改
- 实际验证结果
- 残留风险
```

## Extraction Rules

- `本次目标` 优先取自 `CURRENT_TASK.md` 的当前目标。
- `当前状态`、`已完成`、`剩余工作` 优先取自 `CURRENT_TASK.md` 的状态、验收、下一步。
- `范围与约束` 优先取自 `CURRENT_TASK.md` 的范围，再补当前请求里的限制。
- `验证` 只写已看到的真实命令、回读、诊断或检查；没有证据就写 `[待确认]`。
- `风险与未知` 优先写未验证项、运行时未刷新项、状态文件可能过期等真实风险。
- `直接相关文件` 只列出已明确关联的 1 到 3 个文件；不明确就写 `[待确认直接相关文件]`。

## Common Mistakes

- 把整段聊天改写成流水账
- 猜测尚未验证的进度或测试结果
- 把 `CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md` 全量复述进去
- 输出摘要加提示词两份，导致用户还要再手工裁剪
