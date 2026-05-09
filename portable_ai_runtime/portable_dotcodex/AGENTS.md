# AGENTS.md — OpenCode 工作规则（/home/zazaki）

适用目录：`/home/zazaki`

默认路径：`quick`、`vibe`

## 1. 优先级

- 更近层级的 `AGENTS.md` 优先
- 其次遵循本文件，再其次遵循项目文档与 OpenCode 默认行为
- 任何本地规则都不能绕过安全边界、审批策略或沙箱限制

## 2. 核心原则

- 结论必须基于代码、配置、命令结果或文档证据，禁止猜测
- 优先复用项目既有实现、标准生态和官方 SDK；优先修缺陷，再做新增
- 默认自主推进；仅在缺少关键事实或涉及高风险操作时询问用户
- 不得虚构工具、MCP、文件、外部状态或命令结果；不得把 `~/.config/opencode/` 当普通项目产物目录滥用
- 规则必须与当前真实配置一致，避免文档漂移

## 3. 交流约定

- 默认使用简短、自然、直接可读的中文
- 非中文统一写成 `英文内容`（中文解释）
- 默认先给一句结论，再补最多 3 个短点；除非用户明确要求，不展开成长文
- 文件路径写正常文本，不做可点击链接；默认一次性完成后再汇报，只有关键不确定时才打断
- 写 README、说明文档、汇报文档时，先贴近同目录既有语气

## 4. 自动触发

### MCP

- `serena`：语义级代码搜索、跨文件重构、代码结构理解
- `shrimp-task-manager`：多步骤任务跟踪、拆分、执行辅助
- `fastaicode-image`：生图、改图
- `repo-audit`：`git commit` 前审计

### Skills

- `vibe`：多文件修改、跨轮跟踪、冻结 requirement/plan、较强验证闭环，或用户明确提到 `vibe`
- `systematic-debugging`：出现 bug、测试失败、构建失败、意外行为，且尚未完成根因分析
- `brainstorming`：新增功能、行为修改、方案探索、需求设计，且尚未完成设计确认
- `writing-plans`：已经有设计/spec，且实现步骤达到 3 步及以上、涉及多文件修改、或需要跨轮执行
- `verification-before-completion`：准备声称任务完成、问题已修复、结果已通过、或准备进入提交判断前

## 5. 执行路径

- `quick`：简短问答、单点排查、轻量脚本、单文件或小改
- `vibe`：用户显式提到 `vibe`，或任务涉及多文件修改、跨轮跟踪、冻结 requirement/plan、较强验证闭环
- `vibe` 默认阶段：`skeleton_check` → `deep_interview` → `requirement_doc` → `xl_plan` → `plan_execute` → `phase_cleanup`
- `vibe` 产物默认落点：`docs/requirements/`、`docs/plans/`、`outputs/runtime/vibe-sessions/<run-id>/`
- `vibe` 下 requirement 和 plan 各只保留一份权威文档；执行阶段不得再造第二套正式 requirement 或正式 plan
- 没有用户明确授权时，不自行展开多代理

## 6. 治理入口

- 长期稳定原则见 `rules/ai/governance-principles.md`
- 任务级路由细则见 `rules/ai/routing-rules.md`
- 并行 / 串行派发协议见 `workflows/ai/subagent-routing.md`
- 任务闭环规则见 `rules/ai/task-closure.md`
- 记录位置规则见 `rules/ai/recording-rules.md`
- 通用验证规则见 `rules/ai/verification-rules.md`
- 代理模式选择见 `rules/ai/agent-mode-selection.md`
- 提交与交付规则见 `rules/ai/commit-and-delivery-rules.md`
- 具体任务流程见 `workflows/ai/`
- 高代价坑点、工具差异、trigger 样本见 `references/ai/`
- 当前 `~/.config/opencode/` 已启用状态文件体系：`CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md`、`handoff/`

## 7. 必须确认的事项

- 删除核心配置文件
- 破坏性数据或 schema 变更
- `git push`、远端合并、远端发布
- 越过当前沙箱或权限边界的命令
- 连续三次同类失败后仍要尝试新策略
- 清空、重写或迁移既有 `AI_GUIDE.md` 历史内容
