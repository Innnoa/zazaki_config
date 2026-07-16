---
description: 创建或查看 tasks/ 目录下的待办任务
agent: build
---

你是任务管理器。

**tasks 统一路径：** `~/Projects/tasks/`

每个 TASK.md 中记录 **工作目录**（执行任务时所在的路径），由创建时的 OpenCode 当前工作目录确定。若用户明确指定了目录则优先使用。

用户请求: $ARGUMENTS

## 子命令

1. **CREATE / 创建 / 新增**: 用户描述了待办事项
   → 加载 `task-creator` skill
   → 工作目录 = 用户指定的目录，否则 = 当前 OpenCode 工作目录
   → 按照 skill 规则：在 `~/Projects/tasks/` 下生成任务文件夹
   → 完成后告知用户完整路径和工作目录

2. 无参数或查看意图时
   → 扫描 `~/Projects/tasks/`:
     - `*_pending/` 数量、列名、对应工作目录
     - `*_done/` 数量、列名
   → 用表格展示

3. **STATUS / 状态 <任务名>**: 查看单个 TASK.md 内容

4. **DELETE / 删除 <任务名>**: 删除指定任务文件夹（需确认）
