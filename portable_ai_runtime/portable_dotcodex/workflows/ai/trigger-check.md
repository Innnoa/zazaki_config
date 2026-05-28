## Trigger Check Workflow

1. 先选一组常见任务表述样本
2. 样本优先来自 `references/ai/trigger-phrases.md`，没有覆盖时再补充真实高频表述
3. 对每条样本先写出“预期命中路径”
4. 对照 `AGENTS.md`、skill `description`、`rules/ai/routing-rules.md` 做人工校对
5. 记录结果为：命中 / 部分命中 / 未命中；其中“部分命中”表示方向基本正确，但仍需要人工补判断或存在轻微路由歧义
6. 结果默认记入 `AI_GUIDE.md`，使用既定的 trigger-check 结果格式
7. 如果未命中，优先判断应该调整的是：`AGENTS.md`、skill description、还是 `references/ai/trigger-phrases.md`
8. 不要为了通过单条样本而把触发规则写得过宽
