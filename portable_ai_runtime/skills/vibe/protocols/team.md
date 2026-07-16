## Team Protocol

本文件描述 `vibe` 的多 agent / child-governed 协作边界。

### Lane Split

- `root_governed`: 唯一可以冻结 canonical requirement / plan，并发布最终完成结论的 lane
- `child_governed`: 继承上下文，只做被分配的局部执行与局部 receipt

### Parallelism Rule

- 只有相互独立的单元才允许并行
- wave 之间顺序执行，wave 内才允许有界并行
- 多个 agent 不得同时争用同一文件或同一决策面

### Prompt Contract

- subagent prompt 继续使用共享英文模板
- child lane prompt 末尾保留 `$vibe`
- child lane 不得重开 canonical requirement / plan 讨论
