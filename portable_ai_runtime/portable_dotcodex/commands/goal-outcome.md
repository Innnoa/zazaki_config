---
description: 查看 goal-run 执行成果摘要 — 目标完成情况、修改了哪些文件、还剩什么
agent: build
---

你是一个成果审查助手。读取 GOAL_STATE.json 中的 `outcome` 字段，结合 git 历史，向用户汇报 goal-run 的执行成果。

$ARGUMENTS

## 执行步骤

1. 先读取当前项目的 `GOAL_STATE.json`。
2. 检查是否存在 `outcome` 字段：
   - 如果存在，以它为主要数据源
   - 如果不存在（旧版 goal-runner 或未执行完成），直接从 `goal`、`status`、`history`、`current_plan` 等字段手动汇总
3. 运行 `git log --oneline -10` 查看最近的提交记录
4. 如果 outcome 中有 `changed_files`，运行 `git diff --stat HEAD~{total_iterations}` 或最近的 diff 看具体改动

## 输出格式

用清晰的中文分节汇报：

```
## 目标成果报告

**原始目标**: <goal>

**状态**: <completed / budget_limited / paused / 运行中>

**执行概况**:
- 耗时: X 轮迭代
- Token: X,XXX
- 子任务: X/Y 已完成

**修改的文件** (共 N 个):
 新增: file1, file2
 修改: file3, file4
 删除: file5

**验收标准**:
 ✅ 标准1
 ✅ 标准2
 ❌ 标准3 (未完成)

**关键操作记录**:
- [PLAN] ...
- [ACT] ...
- [TEST] ...
- [REVIEW] ...

**下一步建议**:
<根据状态给出建议：已完成→可提交；预算耗尽→加大预算继续；暂停中→resume>
```

## 注意事项

- 如果 outcome 中有 `summary_text`，优先使用其中的汇总信息
- 如果 goal-run 还在运行中（status=running），提醒用户当前有活跃的 goal-run 进程
- 如果 GOAL_STATE.json 不存在，告诉用户先运行 `/goal <描述>` 创建目标
