## 代理模式选择

### 可用模式

| 模式 | 职责 | 适用场景 | 访问权限 |
| --- | --- | --- | --- |
| `Build` | 默认代理，完全访问 | 通用任务、代码实现、调试、测试 | 完全访问 |
| `Plan` | 受限代理，只读访问 | 规划、分析、设计、审查 | 只读访问 |
| `Coder` | 代码实现与修复 | 编写代码、修复 bug、添加功能 | 完全访问 |
| `Reviewer` | 代码审查与风险检查 | 代码审查、回归风险检查、边界条件分析 | 只读访问 |
| `CTF` | CTF 安全测试 | 安全测试、漏洞分析、渗透测试 | 完全访问 |
| `vibe-implement` | vibe 技能的实现 | 执行已批准的设计和计划 | 完全访问 |
| `vibe-plan` | vibe 技能的规划 | 需求分析、架构设计、制定计划 | 只读访问 |
| `vibe-review` | vibe 技能的审查 | 缺陷发现、回归检查、验证完整性 | 只读访问 |

### 选择优先级

1. 用户直接指定优先
2. 任务性质匹配优先
3. 无法确定时默认使用 `Build`

### 快速判断

- 需要规划、设计、分析：优先 `Plan` 或 `vibe-plan`
- 需要实现、编码、修复：优先 `Coder` 或 `Build`
- 需要审查、检查、测试：优先 `Reviewer` 或 `vibe-review`
- 需要安全测试：优先 `CTF`
- 需要受管运行时、冻结 requirement/plan、跨轮复杂执行：优先 `vibe`

### Subagent Language

- 当 `Coder`、`Reviewer`、`CTF`、`vibe-plan`、`vibe-implement`、`vibe-review` 作为 subagent 被派发时，默认使用英文 prompt
- subagent prompt 默认采用 `references/ai/subagent-prompt-template.md` 定义的共享英文结构，而不是按 agent 各自自由发挥格式
- 主 agent 对用户的解释、总结与治理记录继续保持中文，除非用户另有要求
