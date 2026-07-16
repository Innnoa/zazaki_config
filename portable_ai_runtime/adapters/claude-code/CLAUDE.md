# CLAUDE.md — AI Governance Runtime (Claude Code 适配)

适用目录：当前项目

## 优先级
- 更近层级的 AGENTS.md 优先
- 其次遵循本文件和核心规则
- 任何本地规则都不能绕过安全边界

## 入口
首先读取 AGENTS.md（与 CLAUDE.md 同级目录的通用治理入口），然后根据任务类型按路由规则选择对应的 workflow。

## 会话纪律
- 每个新任务必须重新读取入口并重新路由
- 长会话（>100000 tokens）进入预警态
- 任务完成前执行 AAR 四问

## 核心规则文件
- rules/ai/routing-rules.md       —— 任务路由
- rules/ai/task-closure.md         —— 任务闭环
- rules/ai/verification-rules.md   —— 验证规则

## 行为准则
- 结论基于证据，禁止猜测
- 默认自主推进，高风险操作询问用户
- 优先最小变更并补齐验证
