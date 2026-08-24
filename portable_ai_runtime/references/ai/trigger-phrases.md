## Trigger Phrases

此文件记录常见任务表述与推荐命中路径，用于人工校对 trigger wording，不作为唯一权威源。

| 常见表述 | 预期命中 | 检查用途 |
| --- | --- | --- |
| “这个 bug 为什么还没修好” | `systematic-debugging` | 校对 bug / 异常类表述是否会先走根因分析 |
| “这个测试怎么突然挂了” | `systematic-debugging` | 校对测试失败表述 |
| “帮我设计一下这个功能” | `brainstorming` | 校对设计前置触发 |
| “这个功能需求还没完全想清楚，先一起收敛一下” | `brainstorming` | 校对需求未确认场景 |
| “设计已经定了，给我拆计划” | `writing-plans` | 校对 spec 已存在时的计划触发 |
| “这个改动要跨几个文件，先拆一下执行步骤” | `writing-plans` | 校对多步骤多文件计划触发 |
| “这个任务可以收尾了吗” | `verification-before-completion` | 校对完成前验证触发 |
| “准备提交前帮我确认一下还有没有缺口” | `verification-before-completion` | 校对提交判断前验证触发 |
| “这个任务很复杂，直接用 vibe 跑” | `vibe` | 校对显式提到 vibe 的场景 |
| “这个要跨轮推进，而且后面还要冻结计划” | `vibe` | 校对复杂长链路场景 |
| “Context 35253 tokens” | 会话预算观察 | 校对会话 token 信息出现时是否会联想到预算规则 |
| “超过 15w 就提醒我开新会话” | 会话预算规则 | 校对长会话提醒表述 |
| “这次只是小补充，不算新任务” | `Session Discipline` | 校对重路由借口拦截表述 |
| “压缩后应该还记得” | `Session Discipline` | 校对压缩后借口拦截表述 |
| “grill me” / “interview me” / “帮我理清” / “逐个确认” | `grill-me` | 校对显式追问触发 |
| “这里有几个方案，帮我看看选哪个” | `grill-me` | 校对决策点识别 → 追问触发 |
| “你觉得应该怎么选” / “帮我做个决定” | `grill-me` | 校对委托决策 → 追问触发 |
| “先别动手，跟我确认一下” / “等我确认再执行” | `grill-me` | 校对用户明确要求确认门禁 |
| “这个代码帮我 review 一下” | `代码审查` | 校对代码审查触发 |
| “帮我设计一下这个 UI” / “这个界面怎么改” | `UI/UX 设计` | 校对 UI 设计触发 |
| “这个改动很小直接改就行” | `直接执行` | 校对单文件小改场景 |
| “多开几个 agent 并行干活” | `subagent-driven-development` | 校对 subagent 并行触发 |
| “帮我把这个任务开个新会话” / “开个新会话继续” | `/new-session` | 校对跨会话粘贴提示词触发 |
| "this bug keeps happening" / "why does this test fail" | `systematic-debugging` | 校对英文 bug/测试失败表述 |
| "design this feature for me" / "help me think through this design" | `brainstorming` | 校对英文设计触发 |
| "this is complex, let's use vibe" / "run this through the vibe pipeline" | `vibe` | 校对英文 vibe 触发 |

这些样本用于人工回归，不代表唯一有效说法；如果真实对话里经常出现新的高频表述，应优先补进这里再做校对。
