---
description: 系统通读当前 AI 治理系统，了解运作方式与能力边界
---

你是治理系统学习器。按以下顺序通读本治理系统，读完每层后**总结该层的核心职责和关键文件**。

用户补充: $ARGUMENTS

## 执行步骤

### 1. 先读架构概览
读 `~/.config/opencode/README.md`，理解五层架构：入口层 → 规则层 → 工作流层 → 参考层 → 运行层。

### 2. 逐层通读

**入口层:**
- `~/.config/opencode/AGENTS.md`

**规则层:**
- 列出 `~/.config/opencode/rules/ai/` 下所有 .md 文件
- 通读 `routing-rules.md`、`verification-rules.md`、`task-closure.md`
- 浏览其余规则文件，提取标题和一句话职责

**工作流层:**
- 列出 `~/.config/opencode/workflows/ai/` 下所有 .md 文件
- 通读 `check-governance-consistency.md`、`subagent-routing.md`
- 浏览其余 workflow，提取标题和触发条件

**参考层:**
- 列出 `~/.config/opencode/references/ai/` 下所有 .md 文件
- 通读 `gotchas.md`、`anti-patterns.md`、`session-budget-rules.md`
- 浏览其余 reference，提取标题

**运行层:**
- 读 `~/.config/opencode/opencode.json`，理解 provider、agent、command、MCP、plugin 接线
- 列出 `~/.config/opencode/skills/` 下所有技能名
- 列出 `~/.config/opencode/commands/` 下所有命令名
- 列出 `~/.config/opencode/scripts/` 下关键脚本
- 读 `~/.config/opencode/plugins/session-governance.ts` 的前 60 行

### 3. 输出总结

完成后输出一份结构化总结，至少包含：
- **路由机制：** 新任务如何选路（Quick Routing 表格 + session discipline）
- **验证门禁：** 完成前必须跑什么、治理变更额外检查什么
- **可用能力：** 已接入的 MCP、技能、命令、脚本
- **关键约束：** 红旗规则、必须确认事项、已知坑点
- **你还需要了解的：** 如果用户有补充（$ARGUMENTS），在这部分展开
