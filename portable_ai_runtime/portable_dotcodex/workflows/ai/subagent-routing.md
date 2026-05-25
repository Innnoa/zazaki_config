## Subagent Routing Workflow

本 workflow 先回答“是否需要派发 subagent，以及串行还是并行”；只有结论允许派发后，才进入 `subagent-driven-development` 等具体执行方式。

1. 本协议只定义 subagent 派发补充判断，不替代 `rules/ai/routing-rules.md` 的正式任务路由
2. 主协调 agent 在决定是否派发 subagent 前，必须先执行本协议；不要先派发、后补判断
3. 先读 `AGENTS.md`、`rules/ai/routing-rules.md` 与当前任务约束，确认本次是否真的需要 subagent
4. 按以下原则判断：
   - 能单 agent 直接完成的任务，不为“看起来更快”而派发 subagent
   - 信息不足或边界未明时，先串行探索，再决定是否并行
   - 只有子任务独立、边界清楚、几乎不共享文件或决策时，才允许并行
   - 多个子任务会争用同一文件、同一模块、同一状态或同一验证链路时，优先串行
   - 并行收益如果不明显大于协调、去重和汇总成本，优先串行
   - 最终结论、最终验证和最终输出必须由主 agent 串行完成
5. 用以下判断表做快速判定：

| 判断项 | 满足时更适合串行 | 满足时更适合并行 |
| --- | --- | --- |
| 任务拆分性 | 边界还不清楚 | 边界已经清楚 |
| 上下文耦合 | 需要共享大量背景 | 每个子任务只需最小上下文 |
| 文件冲突风险 | 可能同时改同一文件 | 可天然分区，避免同改 |
| 决策依赖 | 后一步依赖前一步结果 | 子任务之间几乎无前后依赖 |
| 验证方式 | 需要统一逐步收敛验证 | 可先局部验证，再统一总验 |
| 协调成本 | 汇总去重成本高 | 汇总接口明确、回收成本低 |

6. 输出结论时固定使用以下格式，不增删 marker：

```text
Decision: Serial | Parallel
Reasoning:
- ...
Plan:
- ...
Guardrails:
- 谁负责最终汇总
- 哪些文件或模块禁止多个 agent 同时修改
- 何时停止并行并回退到串行
```

输出时：`Decision` 行只保留 `Serial` 或 `Parallel` 其中一个值。

7. 执行要求如下：
    - 并行时每个 subagent 只拿最小上下文，只给完成当前子任务所需的信息
    - 避免多个 subagent 同时修改同一文件；如果无法避免，回退为串行或先拆出明确接口
    - 主 agent 不外包最终判断，包括是否完成、是否合格、是否可继续下一步
    - 所有结果返回后，主 agent 必须统一审查、去重、整合、验证，再形成最终输出
    - 一旦开始派发，发给 subagent 的 prompt 一律使用 `references/ai/subagent-prompt-template.md` 的共享英文结构；不要混用中英文指令，也不要为不同 agent 发明不同模板

### Subagent Prompt Structure

- 派发 prompt 必须按 `references/ai/subagent-prompt-template.md` 组织，至少包含：`Role`、`Goal`、`Scope`、`Constraints`、`Inputs`、`Expected Output`、`Verification`
- `Scope` 只写当前子任务边界；`Constraints` 只写硬约束；`Verification` 只写必须回传的检查证据
- 如果需要补充上下文，放进 `Inputs`，不要改写标题名，也不要改成中文标题
- `opencode.json` 中的 command template 只能作为进入某类 subagent 的轻量 wrapper，不应成为第二套结构模板

### 派发控制

- 不要因为 subagent 没有立即返回，就假定它已卡住；必须等显式完成报告
- 不要中途打断 subagent，也不要在未完成前把任务抢回主 agent 自己做
- 派发时模型只能在 `gpt-5.4` 和 `gpt-5.4-mini` 中选择
- 推理强度只能在 `high`、`medium`、`low` 中选择：复杂判断优先 `high`，大多数任务默认 `medium`，简单快扫任务可用 `low`

8. 如果判断结果为串行，先执行最小探索步骤，再按新证据重新评估是否需要并行
9. 如果判断结果为并行，先按共享英文模板写清每个 subagent 的目标、边界、输入、输出与验证要求，再开始派发
10. subagent 完成后，主 agent 负责把结果重新整理成面向用户的中文汇报，除非用户明确要求英文
