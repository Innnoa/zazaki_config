## 更新规则工作流

1. AAR 四问已先行执行（见 task-closure 规则）；此处仅处理有结论（任意一问为"有"）时的后续流程
2. 如果四问全部为“没有”，在当前任务汇报中明确写出“本次无新增规则或坑点”，然后停止
3. 如果任意一问为“有”，先判断该结论属于：规则、坑点、决策、状态更新、还是项目级锚点
4. 快速分类时使用以下判定句：稳定约束变化记为规则；高代价且可复发的问题记为坑点；可复用取舍记为决策；当前执行态变化记为状态更新；项目级验证结论或跨轮增量记为项目级锚点
5. 按 `rules/ai/recording-rules.md` 的记录位置规则选择主落点；如果同时命中多个落点，只保留一个主落点，其他文件最多加一句回链，不做全文重复记录
6. 不要把会话叙事或原始调试过程写进治理 reference 文件
7. 如果本次属于 AI 治理系统变更，在结束前按 `workflows/ai/check-governance-consistency.md` 做一次一致性检查
8. 如新增或修改治理文件引用，顺手确认对应路径真实存在，再进入完成汇报
9. 如果本次变更会影响 `serena`、原生 LSP、MCP、agent prompt 或其他需要 reload / restart / reactivate 才会真正生效的运行面，先按 `references/ai/runtime-refresh-rules.md` 判断刷新要求，再决定是否可以宣称完成
10. 对纯静态治理文档更新，不要伪造 runtime refresh；对运行时生效变更，也不要只用“文件改了”替代刷新后的真实证据
11. 如果本次属于高频治理场景，完成汇报时优先复用 `references/ai/verification-templates.md` 的对应模板；只引用，不在本文件重写模板正文
12. 新增治理检查命令时复用成套结构（脚本 + command + 注册），见 `references/ai/governance-tool-pattern.md`
13. 把组织级规范文档转成 skill 时复用可复用路径，见 `references/ai/doc-to-skill-pattern.md`
