## Runtime Protocol

本文件是 `skills/vibe/SKILL.md` 的按需下钻说明，只细化运行阶段职责，不创建第二套 runtime 权威面。

### Stage Ownership

1. `skeleton_check`
   - 检查仓结构、现有 requirement / plan 痕迹、必要运行前提
   - 若前置条件不满足，先暴露阻塞，不要跳过
2. `deep_interview`
   - 收敛 goal、deliverable、constraints、acceptance、non-goals
   - 信息不足时优先显式提出缺口
3. `requirement_doc`
   - 冻结单一 requirement 文档
   - 后续执行以冻结文档为准，不再以散落聊天记录为真值
4. `xl_plan`
   - 冻结执行计划、internal grade、verification、rollback、cleanup 预期
5. `plan_execute`
   - 按冻结计划执行；如需 specialist 或 child lane，保持边界清晰
6. `phase_cleanup`
   - 回收临时产物，保留必要 proof 与 cleanup receipt

### Artifact Rules

- canonical requirement surface: `docs/requirements/`
- canonical governed execution plan surface: `docs/plans/`
- runtime receipts: `outputs/runtime/vibe-sessions/<run-id>/`

### Delivery Guardrails

- 不得在未完成 verification 前宣称成功
- 不得创建第二 requirement / plan 真值面
- 如 host 行为或插件接线是否生效尚未验证，必须明确写成未确认，而不是默认已生效
