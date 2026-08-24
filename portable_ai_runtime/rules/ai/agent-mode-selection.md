## 代理模式选择

### 作用

定义当前 OpenCode 环境中可用的代理模式及其选择优先级，避免引用不存在的模式导致路由漂移。

### 可用模式

| 模式 | 职责 | 适用场景 | 访问权限 |
| --- | --- | --- | --- |
| `Build` | 默认代理，完全访问 | 通用任务、代码实现、调试、测试 | 完全访问 |
| `Plan` | 受限代理，只读访问 | 规划、分析、设计、审查 | 只读访问 |

> `Build` 和 `Plan` 是 OpenCode 平台内置模式，不由本地 `opencode.json` 控制。

### 选择优先级

1. 用户直接指定优先
2. 任务性质匹配优先
3. 无法确定时默认使用 `Build`

检验：我选择的模式是否匹配任务性质？如果用户没有明确指定，是否已默认使用 `Build`？

### 快速判断

- 需要规划、设计、分析：优先 `Plan`
- 需要实现、编码、修复：使用当前 agent 的 subagent（fixer/designer/oracle 等）
- 需要受管运行时、冻结 requirement/plan、跨轮复杂执行：使用 `vibe` skill

### Subagent Language

- 当 subagent（reviewer、verifier、designer、fixer、explorer、librarian、oracle、councillor 等）被派发时，默认使用英文 prompt
- subagent prompt 默认采用 `references/ai/subagent-prompt-template.md` 定义的共享英文结构，而不是按 agent 各自自由发挥格式
- 主 agent 对用户的解释、总结与治理记录继续保持中文，除非用户另有要求

### 检验句

问自己：`我选择的模式是否匹配任务性质？如果用户没有明确指定，是否已默认使用 Build？`
