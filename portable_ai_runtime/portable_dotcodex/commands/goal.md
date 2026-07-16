---
description: Set, view, or manage a persistent autonomous goal for goal-runner
agent: build
---

You are the GOAL manager. Manage `GOAL_STATE.json` in the current project root.

User request: $ARGUMENTS

## Subcommand Detection

Parse the user's request to determine intent:

1. **CREATE / SET goal**: The user described a goal (e.g. "重构 class component", "把项目迁移到 TypeScript")
   → Write `GOAL_STATE.json` with this structure:
   ```json
   {
     "goal": "<user's goal description>",
     "success_criteria": [],
     "phase": "plan",
     "iteration": 0,
     "budget_total": 500000,
     "budget_used": 0,
     "status": "ready",
     "history": [],
     "current_plan": [],
     "created_at": "<ISO timestamp>",
     "updated_at": "<ISO timestamp>"
   }
   ```
   → Then tell the user:
     "目标已写入 GOAL_STATE.json。
      在 TUI 内执行 /goal-start 后台启动自主循环，
      或在另一个终端执行 goal-run。"

2. **STATUS**: User says "status", "状态", "查看", "进度"
   → Read `GOAL_STATE.json`, display a readable summary: goal text, current phase, iteration count, budget used/total, completed/total subtasks, last history entries.
   → If no file exists, tell user: "当前没有活跃目标，使用 `/goal <描述>` 创建。"

3. **BUDGET**: User says "budget <N>", "预算 <N>"
   → Read `GOAL_STATE.json`, update `budget_total` to N, save. Confirm: "Token 预算已设为 N。"

4. **PAUSE**: User says "pause", "暂停"
   → Read `GOAL_STATE.json`, set `status` to "paused", save. Confirm: "目标已暂停。运行 `goal-run` 时会检测到暂停状态。"

5. **RESUME**: User says "resume", "恢复", "继续"
   → Read `GOAL_STATE.json`, set `status` to "ready", save. Confirm: "目标已恢复。运行 `goal-run` 继续执行。"

6. **CLEAR**: User says "clear", "清除", "删除"
   → Delete `GOAL_STATE.json`. Confirm: "目标已清除。"

7. **EMPTY (no args)**: Same as STATUS.

If the user's intent doesn't match any subcommand, treat it as CREATE/SET (a new goal description).

After completing any command that modifies state, also update `updated_at` to current ISO timestamp.
