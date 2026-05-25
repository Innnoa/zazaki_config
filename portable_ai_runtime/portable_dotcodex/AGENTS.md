# AGENTS.md — OpenCode 工作规则（/home/zazaki）
适用目录：`/home/zazaki`
## 优先级
- 更近层级的 `AGENTS.md` 优先
- 其次遵循本文件，再其次遵循项目文档与 OpenCode 默认行为
- 任何本地规则都不能绕过安全边界、审批策略或沙箱限制
## 核心原则
- 结论必须基于代码、配置、命令结果或文档证据，禁止猜测；优先复用既有实现与标准生态，先修缺陷，再做新增
- 默认自主推进；仅在缺少关键事实或涉及高风险操作时询问用户
- 不得虚构工具、文件、外部状态或命令结果；规则必须与当前真实配置一致，避免文档漂移
## 交流约定
- 默认使用简短、自然、直接可读的中文；非中文统一写成 `英文内容`（中文解释）
- 默认先给一句结论，再补最多 3 个短点；除非用户明确要求，不展开长文
- 文件路径写正常文本，不做可点击链接；`150000 tokens` 以上的最终回答要追加固定提醒：`上下文已超过 150000 tokens，请开启新会话。`
### Always Read
- 非纯信息问答任务：先读 `AGENTS.md`
- 再读 `rules/ai/session-discipline.md`、`rules/ai/routing-rules.md`
- 需要验证时再读 `rules/ai/verification-rules.md`
- 治理系统变更时，再读对应 `workflows/ai/` 与必要 `references/ai/`
### Session Discipline
- 每个新任务都必须重新读取入口并重新路由
- 长会话、压缩、任务类型切换时，视为强制重路由点；`100000 tokens` 进入预警态，`150000 tokens` 进入强提醒态
- 详细规则以 `rules/ai/session-discipline.md`、`references/ai/session-budget-rules.md` 为准
### Common Tasks
- 修 bug：`systematic-debugging` + `workflows/ai/fix-bug.md`
- 新增功能、行为修改、方案探索：`brainstorming`
- 已有设计/spec 且步骤较多：`writing-plans` + `workflows/ai/implement-feature.md`
- 代码审查：`workflows/ai/review.md`
- `vibe`：多文件修改、跨轮跟踪、冻结 requirement/plan，或用户明确提到 `vibe`
- 多子任务且相互独立：先看 `workflows/ai/subagent-routing.md`
- Other / unlisted task：先走 `Always Read`，再匹配最接近 workflow，并说明原因
### Auto-Triggers
- 当任务从修 bug 切到实现、审查、规划或治理时，重读 `rules/ai/routing-rules.md`
- 当发生 `startup`、`clear`、`compact` 或明显上下文压缩时，重走入口
- 当任务涉及会话 token 预算、长会话提醒或开新会话规则时，补读 `references/ai/session-budget-rules.md`
- 当任务属于治理系统变更时，结束前执行 `workflows/ai/check-governance-consistency.md`
- 宣称非琐碎任务完成前，执行 `rules/ai/task-closure.md` 与 `rules/ai/verification-rules.md`
- 当 AAR 产出暂不适合直接进入正式治理面的高价值结论时，按 `rules/ai/recording-rules.md` 写入 `~/docs/ai/AAR_his/AAR_INBOX.md`
### Red Flags - STOP
- `这次只是小补充，不算新任务`
- `我刚刚已经读过这些文件`
- `先做一下，最后再补路由`
- `压缩后应该还记得`
- `文档里写了阈值，就等于已经有运行时门禁`
- `reference 里有就够了，不用放到入口或正式规则`
### Known Gotchas
- 长会话或压缩后不重读入口，很容易错误继承上一轮路径；`100000 / 150000` 阈值若只存在于深层 reference 不会自然激活；当前若无 host hook 证据，不要把治理提醒误报成自动门禁
- 详见 `references/ai/gotchas.md`、`references/ai/session-budget-rules.md`、`references/ai/anti-patterns.md`
## 必须确认的事项
- 删除核心配置文件、破坏性数据或 schema 变更、`git push`、远端合并、远端发布
- 越过当前沙箱或权限边界的命令；连续三次同类失败后仍要尝试新策略；清空、重写或迁移既有 `AI_GUIDE.md` 历史内容
