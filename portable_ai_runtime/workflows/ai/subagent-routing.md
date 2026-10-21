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

- schema contract = `references/ai/subagent-prompt-template.md`（禁止其他 command-wrapper 结构；各字段语义与格式规则以模板为准，不在此重复）
- `opencode.json` 中的 command template 只能作为进入某类 subagent 的轻量 wrapper，不应成为第二套结构模板

### 派发控制

- 不要因为 subagent 没有立即返回，就假定它已卡住；必须等显式完成报告
- 不要中途打断 subagent，也不要在未完成前把任务抢回主 agent 自己做
- 模型由 `oh-my-opencode-slim.json` 的 preset 统一分配，不在 subagent 派发层面逐个指定
- 推理强度只能在 `high`、`medium`、`low` 中选择：复杂判断优先 `high`，大多数任务默认 `medium`，简单快扫任务可用 `low`
- 双端同 spec 改动（如 app 导出 schema + 消费端解析）先各冻结一份 `writing-plans`，用「schema 契约键名表」做两计划的互锁锚点（一端写什么键，另一端就解析什么键），再并行派两个后台 fixer lane；验收时把 fixer 逐条申报的 deviations 清单当一等证据核对，而不是只信 OK
- 前后端拆分先在 spec 冻结「JSON API 契约」（字段名、形状、状态枚举写死，否则两端各自发明字段），再并行派 designer（只写前端文件）与 fixer（只写后端文件），文件互斥零冲突；前端加 `?demo=1` 内嵌样例数据、不发任何 fetch，让 designer 无需后端即可完整自验，后端用真实数据起服 + curl 全端点验收
- 多文件新功能先写一份精确到「字段名与类型」的接口规格（API 签名、结果字典 schema、文件路径、HTTP 契约），再让各 lane 只消费冻结契约、写范围不重叠地并行，最后一次性集成；spec 不精确接口就会漂
- 并行 lane 禁用硬编码的共享临时路径（如 `/tmp/inst`，一条 lane 的 `rm -rf` 会抹掉另一条 lane 正在用的树）；每条 lane 必须用车道唯一路径 `/tmp/<lane>-<rand>`，并在派发提示词里显式禁止共享路径
- 仓库级共享生成目录（如 `installer/runtime/`）是并行 lane 的隐性争用点，各 lane 自测后 `rm -rf` 会互相删掉对方正在校验的生成物；产物要么放车道唯一目录（`runtime/<lane>/` 或 `/tmp/<lane>-<rand>/`），要么显式约定只在自己的单次 shell 调用内「生成 + 快照 + 断言」、不跨调用依赖
- verifier 车道出现无终态停止（`stopped (unconfirmed)` / `no live status entry`、零报告只留中间物）时，不得当作「已完成验证」；改由 root lane 接管执行既定验证项，并在验证报告 Method 节显式声明来源非独立，重试时缩小范围（如给网络型步骤硬限 `timeout` 并标为 optional）

8. 如果判断结果为串行，先执行最小探索步骤，再按新证据重新评估是否需要并行
9. 如果判断结果为并行，先按共享英文模板写清每个 subagent 的目标、边界、输入、输出与验证要求，再开始派发
10. subagent 完成后，主 agent 负责把结果重新整理成面向用户的中文汇报，除非用户明确要求英文
