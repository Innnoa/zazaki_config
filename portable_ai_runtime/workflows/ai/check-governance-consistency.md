## 治理一致性检查工作流

适用场景：修改 AI 治理系统中的规则、工作流、reference、agent prompt、运行配置或状态文件时。

1. 先列出本次触及的治理面：`AGENTS.md`、`rules/ai/*`、`workflows/ai/*`、`references/ai/*`、`agents/*`、`opencode.json`、`CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md`
2. 只检查与本次变更直接相关的面；如果某一层应受影响但未更新，明确记录原因
3. 逐项核对以下清单：
   - 规则是否仍与 `AGENTS.md` 保持一致，没有新增冲突表述
   - `rules/ai/*`、`workflows/ai/*`、`references/ai/*` 之间是否只有一个主落点，没有重复造第二套规则
   - 如果修改了 workflow，相关 verification 要求是否同步到 `rules/ai/verification-rules.md`
   - 如果修改了治理流程，`CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md` 是否只补最终仍可复用的结论
   - 如果修改了 subagent / agent prompt、运行配置或命令模板，`agents/*` 与 `opencode.json` 是否仍和治理规则一致
   - 如果 skill、agent 或 command 文本声明了按需阅读的协议、模板或辅助文件，这些被引用路径是否真实存在
   - 如果修改了 `skills/vibe/config/*.json` 的路径引用，是否已按 `references/ai/vibe-path-classification-rules.md` 区分 `local_required`、`runtime_generated`、`projection_only`、`install_only`、`external_tooling`、`optional_material`
   - 所有新增或引用的文件路径是否真实存在
   - 新 reference 是否保持稀疏，只放高价值锚点、模板或坑点，不写长篇会话叙事
4. 确认所有被引用的文件路径都真实存在；新增引用时同步修正失效路径
5. 如果涉及状态文件，只保留当前任务、可复用决策或项目级锚点，避免重复抄写同一结论
6. 在最终汇报或完成声明前，明确写出：检查范围、实际核对结果、发现的问题与处理结果
7. 如发现冲突、漂移或缺少落点，先修正文档，再进入正常验证或交付判断
8. 如果本次治理变更导致异常行为，回退步骤：
   - 用 `git diff --stat` 确认本次变更范围
   - 最小回滚命令：`git checkout -- <变更文件>` 或 `git revert <commit>`
   - 回滚后重跑 `bash scripts/ai-governance-smoke-check.sh` 确认恢复
