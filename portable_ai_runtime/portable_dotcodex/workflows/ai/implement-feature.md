## 实现功能工作流

1. 先读 `AGENTS.md` 和 `rules/ai/routing-rules.md`
2. 涉及实现导向的设计前，先用 `brainstorming`
3. 先产出或确认设计产物，再进入实现
4. 多步骤工作在实现前先用 `writing-plans`
5. 实现过程中，涉及编写后即时诊断的问题优先看原生 LSP；涉及跨文件符号定位或结构化改动时优先用 `serena`
6. 优先做最小正确实现，避免顺手扩范围
7. 运行与任务匹配的验证；若实现同时改到治理层、subagent prompt/routing 或运行配置，按 `references/ai/verification-templates.md` 选对应高频模板组织证据
8. 宣称完成前，按 `rules/ai/task-closure.md` 走闭环
