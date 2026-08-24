## 设计决策验证流水线（design-validation-pipeline）

两个互补协议的组合链路，用于验证设计决策：

- grill-me（访谈设计者，锁定"我要什么"）→ intuition-probe（盲测用户/开发者直觉，验证"默认会伸手拿什么"）→ 偏差处优先对齐到 LLM 猜测。
- 适用于任何有具体接口的设计阶段（API 签名、配置格式、CLI 参数、UI 组件）。
- 对应关系：grill-me 锁定设计者决策，intuition-probe 验证用户期望；两者结论冲突时，按 intuition-probe 核心原则"猜到的就是对的"对齐到 LLM 猜测。
- 触发入口：`skills/intuition-probe/SKILL.md`（用户直接入口），流程细则见 `rules/ai/grill-me-protocol.md` 与 `rules/ai/intuition-probe-protocol.md`。
