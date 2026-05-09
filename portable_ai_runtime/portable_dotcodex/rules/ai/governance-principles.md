## AI 治理原则

### 作用

本文件只记录这套 AI 治理系统最值得长期保持稳定的少数原则。

它不替代 `routing-rules.md`、`recording-rules.md`、`task-closure.md` 或各类 workflow 细则，只作为长期不应轻易漂移的上层约束。

### 1. 路由单一权威源

- 任务路径判定细节只认 `rules/ai/routing-rules.md`
- `AGENTS.md` 只保留顶层触发意图
- 设计文档、reference 和 trigger phrase 文件只保留摘要、示例或人工校对用途
- 是否派发 subagent、以及串行还是并行，属于执行协议判断，正式协议见 `workflows/ai/subagent-routing.md`。

### 2. 非琐碎任务必须闭环

- 没有经过验证、AAR 四问和记录位置判断的非琐碎任务，不算完成
- 四问全部为“没有”时，也要明确写出“本次无新增规则或坑点”

### 3. 同一结论只保留一个主落点

- 默认只写一个主落点
- 其他文件最多加一句回链，不做全文重复记录
- 不允许把同一结论在 `CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md`、`references/ai/*` 中重复铺开

### 4. references 必须稀疏且真实

- `references/ai/*` 只收真实高价值样本
- 没有复发价值、没有明显成本、或单看代码就能看出来的内容，不进入 reference
- reference 不是聊天残渣存放区，也不是大而全知识库

### 5. trigger wording 必须持续对齐真实表达

- skill `description`、`AGENTS.md` 的自动触发语句、`routing-rules.md` 的路径条件，应持续围绕真实用户表述收紧
- 发现高频真实表述命不中时，先补样本，再调 wording，再判断是否要调路由
- 不为了通过单条样本把整体触发规则写得过宽
