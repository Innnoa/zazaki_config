## 规划与实现工作流

1. 先读 `AGENTS.md` 和 `rules/ai/routing-rules.md`
2. 明确目标、约束和验收标准
3. 涉及实现导向的设计前：

   - [ ] 是否已有经过用户批准的设计方案？

   未通过 → **STOP。返回 brainstorming（`skills/brainstorming/SKILL.md`），呈现设计并获得用户批准后再返回。**
4. 产出或更新设计产物，确保方案可执行；规划产物默认放在 `docs/requirements/` 和 `docs/plans/`（与 vibe 产物落点一致，均为 gitignore 排除的 AI 产物目录）
5. 多步骤工作在实现前：

   - [ ] 是否已有完整的实现计划？

   未通过 → **STOP。返回 writing-plans（`skills/writing-plans/SKILL.md`），产出计划后再返回。**
6. 实现过程中：诊断类问题优先看原生 LSP；跨文件符号定位或结构化改动优先用 `serena`
7. 优先做最小正确实现，避免顺手扩范围
8. 运行与任务匹配的验证
9. 如果实现同时改到治理层、subagent prompt/routing 或运行配置，按 `references/ai/verification-templates.md` 选对应高频模板组织证据
10. 如果规划或实现会修改 AI 治理系统，显式包含 `workflows/ai/check-governance-consistency.md`
11. 宣称完成前，按 `rules/ai/task-closure.md` 走闭环
