## AI 记录规则

### 规则优先级

- 本文件用于细化 `AGENTS.md` 中的状态文件与读写规则。
- 与 `AGENTS.md` 冲突时，以 `AGENTS.md` 为准。

### 记录位置

- `CURRENT_TASK.md`：当前目标、状态、下一步
- `DECISIONS.md`：可复用技术决策
- `AI_GUIDE.md`：项目级锚点、关键验证结论、跨轮增量
- `~/docs/ai/AAR_his/AAR_INBOX.md`：AAR 价值摘录暂存池，等待后续统一整理
- `handoff/`：会话交接摘要
- `rules/ai/`：稳定治理规则
- `references/ai/`：高代价、可复发坑点
- `workflows/ai/`：有顺序的执行流程

### 不应写入这里的内容

- 不要把原始会话日志写进 `rules/ai/`
- 不要把原始会话日志写进 `references/ai/`
- 不要把 `~/docs/ai/AAR_his/AAR_INBOX.md` 当作正式规则库或状态文件使用
- 不要把治理文件当作 git 历史替代品

### 新规则或新坑点的录入门槛

只有至少满足以下三条中的两条，才新增规则或坑点记录：

1. 大概率还会再次发生
2. 漏掉它会明显浪费时间、质量或验证成本
3. 单看代码本身不容易直接看出来

### 快速判断

- 当前执行状态变化：主落点写 `CURRENT_TASK.md`。
- 可复用取舍变化：主落点写 `DECISIONS.md`。
- 项目级验证锚点、跨轮增量、trigger-check 汇总结论：主落点写 `AI_GUIDE.md`。
- AAR 刚产生、暂时还不应直接进入正式治理面的高价值摘录：先写 `~/docs/ai/AAR_his/AAR_INBOX.md`。
- 高代价、可复发坑点：主落点写 `references/ai/`。
- 稳定治理约束变化：主落点写 `rules/ai/`。
- 有顺序的执行步骤变化：主落点写 `workflows/ai/`。
- 默认只保留一个主落点；其他文件最多加一句回链，不做全文重复记录。

### 记录格式优先级

- 先选最轻的正确格式：一条 bullet 优先于一整段，一整段优先于新文件
- 只有现有文件无法承载时，才新增同类治理文件
- `references/ai/*` 初期保持稀疏，只有满足“新规则或新坑点录入门槛”的真实高价值样本时才新增条目。
- `~/docs/ai/AAR_his/AAR_INBOX.md` 只保留最小字段：日期、task、type、value、suggested_destination、status。
