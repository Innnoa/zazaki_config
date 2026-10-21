# AGENTS.md — OpenCode 工作规则（$HOME）
适用目录：`$HOME`
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
- 涉及用户决策时，遵循 `rules/ai/grill-me-protocol.md`：一次一问、环境优先、每问带推荐、深度优先遍历、确认共识后再行动
- 涉及"API/配置/CLI/UI 是否直觉"时，遵循 `rules/ai/intuition-probe-protocol.md`："猜到的就是对的"，盲测 LLM 的默认期望，对齐到猜测
### Always Read
- 非纯信息问答任务：先读 `AGENTS.md`
- 再读 `rules/ai/routing-rules.md`
- 需要验证时再读 `rules/ai/verification-rules.md`
- 治理系统变更时，再读对应 `workflows/ai/` 与必要 `references/ai/`
### Session Discipline
- 每个新任务都必须重新读取入口并重新路由
- 长会话、压缩、任务类型切换时，视为强制重路由点；`100000 tokens` 进入预警态，`150000 tokens` 进入强提醒态
- 详细规则以 `rules/ai/routing-rules.md` 的"会话纪律"部分、`references/ai/session-budget-rules.md` 为准
### Quick Routing

| Task | Required Reads | Workflow |
| --- | --- | --- |
| Bug fix / test failure / build failure | `rules/ai/routing-rules.md` | `systematic-debugging` → `workflows/ai/fix-and-review.md` |
| New feature / behavior change / exploration | `rules/ai/routing-rules.md` | `brainstorming` |
| Has spec, multi-step, multi-file | `rules/ai/routing-rules.md` | `writing-plans` → `workflows/ai/plan-and-implement.md` |
| Code review | `workflows/ai/fix-and-review.md` | `requesting-code-review` → `workflows/ai/fix-and-review.md` |
| Vibe (multi-file, cross-turn, frozen req/plan) | `skills/vibe/SKILL.md` | `vibe` |
| Multi-subtask | `workflows/ai/subagent-routing.md` | `subagent-driven-development` |
| Governance change | `workflows/ai/check-governance-consistency.md` | `customize-opencode`（治理仓内非琐碎变更按下方覆盖规则优先被 `vibe` 接管） |
| UX design / review | `rules/ai/routing-rules.md` | `ux-design` skill → internal Common Tasks |
| 中文写作 / 小说创作 | `docs/writing-stack.md` | 创作 `human-writing` → 改稿 `humanizer-zh` → 检查 `skills/human-writing/scripts/check_prose.py` |
| Other / unlisted | `rules/ai/routing-rules.md` | Match closest workflow, explain why |

> **覆盖规则**：上表中各场景若同时满足非琐碎条件（涉及 2+ 文件修改 / 跨会话 / 新设计决策 / 治理系统），优先走 `vibe` 受管运行时，不走独立 workflow。路由优先级：安全/阻断风险 > vibe > 明确 workflow > 兜底路径。

### Auto-Triggers
- 同一会话中每个新任务：重新读取 `AGENTS.md`，重新匹配路由，重新读取该路由要求的所有文件
- 当任务从修 bug 切到实现、审查、规划或治理时，重读 `rules/ai/routing-rules.md`
- 当发生 `startup`、`clear`、`compact` 或明显上下文压缩时，重走入口
- 当任务涉及会话 token 预算、长会话提醒或开新会话规则时，补读 `references/ai/session-budget-rules.md`
- 当任务属于治理系统变更时，结束前执行 `workflows/ai/check-governance-consistency.md`
- 宣称非琐碎任务完成前，执行 `rules/ai/task-closure.md` 与 `rules/ai/verification-rules.md`
- 当 AAR 产出暂不适合直接进入正式治理面的高价值结论时，按 `rules/ai/recording-rules.md` 写入 `~/docs/ai/AAR_his/AAR_INBOX.md`
- 当用户需要网站结构化数据（价格/商品/物流/房产/市场数据）或提到 parse.bot 时，加载 `parse-api` skill（详见 `rules/ai/auto-trigger-rules.md`）
- 当用户进行网络小说/网文/故事等中文创作或要求"活人感"时，加载 `human-writing` skill（详见 `rules/ai/auto-trigger-rules.md`）
- 当用户要求画流程图、架构图、时序图、ER 图、思维导图、拓扑图等结构化图表或提到 drawio 时，加载 `diagram-drawio` skill（详见 `rules/ai/auto-trigger-rules.md`）
- 当用户进行 Ansible/SSH/Linux 服务器部署、配置模板、备份恢复或 cron/systemd 运维自动化时，加载 `ansible-ssh-deployment` skill（详见 `rules/ai/auto-trigger-rules.md`）
- 当问题涉及个人知识库内容（个人笔记/乐理/学习导航项目，或用户说"我的笔记/知识库"）时，先用 `zazaki-rag` 的 `search_knowledge` 检索再回答（详见 `rules/ai/auto-trigger-rules.md`）
### Red Flags - STOP
- `这次只是小补充，不算新任务`
- `我刚刚已经读过这些文件`
- `先做一下，最后再补路由`
- `压缩后应该还记得`
- `文档里写了阈值，就等于已经有运行时门禁`
- `reference 里有就够了，不用放到入口或正式规则`

完整借口表及反制措施见 `references/ai/rationalizations.md`。
### Known Gotchas
- 长会话或压缩后不重读入口，很容易错误继承上一轮路径；`100000 / 150000` 阈值若只存在于深层 reference 不会自然激活；当前若无 host hook 证据，不要把治理提醒误报成自动门禁
- 详见 `references/ai/gotchas.md`（系统行为坑点）、`references/ai/session-budget-rules.md`（预算阈值）、`references/ai/anti-patterns.md`（Agent 行为反模式）
涉及代码审查、修复或治理变更时，主动检查 `references/ai/anti-patterns.md` 中的相关反模式。
## 必须确认的事项
- 删除核心配置文件、破坏性数据或 schema 变更、`git push`、远端合并、远端发布
- 越过当前沙箱或权限边界的命令；连续三次同类失败后仍要尝试新策略；清空、重写或迁移既有 `AI_GUIDE.md` 历史内容
