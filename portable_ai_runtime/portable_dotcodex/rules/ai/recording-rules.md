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

### AI 生成文件的标准化头部

所有由 AI 系统生成并维护的状态文件（`CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md`、`handoff/` 下文件、`~/docs/ai/AAR_his/AAR_INBOX.md` 等），必须在文件首行放置标准化标记：

```markdown
<!-- ai-generated: true | do-not-version-control -->
```

标记后必须跟一个空行，再开始文件正文。

该标记同时服务于：
- 人工阅读时明确文件来源与版本控制策略
- `repo-audit` MCP 的动态检测：扫描文件首行即可识别，无需更新静态路径列表
- `.gitignore` 配合 `git add` 层面的直接排斥

新增记录位置时，优先确认是否有 `ai-generated` 标记；若当前没有，先补标记再写入内容。

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

### 检验句

问自己：`这条结论我准备写在哪里？那个位置是它的主落点吗？有没有已经在其他地方全文重复过？`
如果答案不是清晰确定的，先查 recording-rules.md 的记录位置规则，再落笔。

### 规则清退机制

记录不是只增不减的，否则会膨胀成误导性文档。

清退判断：

- 技术已移除 -> 直接删除
- 仍在迁移 -> 标注作用域（注明适用版本/范围）
- 不确定是否还有用 -> 加 `<!-- DEPRECATED: YYYY-MM-DD -->` 注释，保留一个治理迭代周期后再删

评估式拆分（拆分前问）：

1. 话题可分离？
2. 导航困难？
3. 拆后能独立存在？

评估式合并（合并前问）：

1. 话题相关？
2. 合并后更好找？
3. 合并后不超标？
