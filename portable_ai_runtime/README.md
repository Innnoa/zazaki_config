# OpenCode AI 治理系统

这个仓库是当前 OpenCode 全局配置与 AI 治理层的权威目录，目标不是只存一份 `opencode.json`，而是把路由、验证、状态、技能、运行时护栏和自动化脚本收口到同一个可维护的配置面。

## 1. 系统定位

这套系统解决的是三个问题：

- 让 AI 在长会话、多任务、跨轮协作里仍然按统一规则工作。
- 让配置、技能、命令、MCP、插件和验证脚本有清晰边界，而不是散落在聊天历史里。
- 让高风险动作、治理修改、会话预算、任务闭环和 AAR 有真实落点，而不是依赖临时口头约定。

它既是 OpenCode 的运行配置仓，也是当前个人 AI 治理系统的实现仓。

## 2. 架构概览

可以把当前系统看成五层：

1. 入口层：`AGENTS.md`
2. 规则层：`rules/ai/`
3. 工作流层：`workflows/ai/`
4. 参考与模板层：`references/ai/`、`templates/`
5. 运行层：`opencode.json`、`plugins/`、`skills/`、`commands/`、`scripts/`

配套还有一层状态面：`CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md`、`handoff/`。

### 2.1 入口层

`AGENTS.md` 是薄壳入口。它只负责：

- 定义总原则
- 指定 Always Read
- 给出 Quick Routing
- 定义会话纪律、红旗和已知坑点

入口层尽量保持短，不在这里重复展开长 checklist。真正的规则细节下沉到 `rules/ai/`。

### 2.2 规则层

`rules/ai/` 是单一权威约束面，当前高频规则包括：

- `routing-rules.md`：任务路由与会话纪律
- `verification-rules.md`：完成前必须跑什么验证
- `task-closure.md`：非 trivial 任务的闭环定义
- `recording-rules.md`：状态文件、AAR、规则记录写到哪里
- `commit-and-delivery-rules.md`：提交与交付要求
- `agent-mode-selection.md`：Build / Plan 平台模式与 subagent 选择边界

这层的职责是定义规则，不承载具体任务步骤。

### 2.3 工作流层

`workflows/ai/` 负责把规则串成可执行路径，当前常用入口包括：

- `check-governance-consistency.md`：治理修改前后的对齐检查
- `fix-and-review.md`：修复与审查路径
- `plan-and-implement.md`：有 spec 的多步实现路径
- `subagent-routing.md`：何时串行、何时并行、如何派发 subagent
- `update-rules.md`：新经验进入正式治理面的判断路径

简单说，规则层回答“必须满足什么”，工作流层回答“按什么顺序做”。

### 2.4 参考与模板层

`references/ai/` 放的是高价值锚点，不是第二套规则。它主要承载：

- 预算与长会话规则
- smoke check 参考
- verification 模板
- runtime refresh 规则
- gotchas / anti-patterns
- subagent prompt 模板

`templates/` 放的是可复用骨架，比如：

- `templates/skill/SKILL.md`
- `templates/shells/AGENTS.md`
- `templates/protocol-blocks/session-discipline.md`
- `templates/protocol-blocks/aar-check.md`

### 2.5 运行层

运行层决定系统真正怎么工作：

- `opencode.json`：provider、agent、command、MCP、plugin 总配置
- `plugins/session-governance/`：运行时治理插件
- `skills/`：按需加载的能力包
- `commands/`：显式命令入口
- `scripts/`：机械检查、goal-runner、安装与辅助脚本

这层才是“文档写了以后到底能不能跑起来”的关键。

## 3. 当前功能

基于当前仓内容，系统已经具备这些能力。

### 3.1 治理路由与会话纪律

- 每个新任务都要求重新读取入口并重路由。
- 不允许压缩后盲继承上一轮路径。
- 长会话有 `100000 / 150000` token 预算规则。
- 对治理修改、验证、交付、记录和 handoff 有明确约束。

### 3.2 状态与跨轮连续性

- `CURRENT_TASK.md`：当前任务唯一权威状态
- `DECISIONS.md`：可复用技术决策
- `AI_GUIDE.md`：项目级锚点与关键验证结论
- `handoff/`：跨会话交接

这几类文件都带统一 AI 生成标记，用于 repo-audit 和版本控制隔离。

### 3.3 运行时护栏

- `plugins/session-governance/` 会在运行时注入治理上下文
- 对治理文件编辑做额外确认
- 对过大的治理文件做拒绝保护
- 在 compaction 时保留任务状态、决策和预算规则

注意：它是事件级治理护栏，不等于基于 token 计数的硬门禁。

### 3.4 Provider 与模型入口

当前 `opencode.json` 里已接入：

- `mimo`
- `openai`
- `deepseek`

默认主模型目前是：

- `openai/gpt-5.6-sol`

同时暴露了若干 agent 入口，例如：

- `reviewer`
- `verifier`
- `openai-56-sol`
- `deepseek-flash`
- `deepseek-pro`

### 3.5 MCP 与外部能力接线

当前配置了多类 MCP：

- 文档：`context7`
- 审计：`repo-audit`
- 搜索：`brave-search`
- 抓取：`fetch`
- 浏览器：`lightpanda`
- 图片：`fastaicode-image`
- GitHub：`github`
- 思维链：`sequential-thinking`
- 微信：`wechat-download-api`

这让治理系统不只是“会说规则”，而是能真的调用外部能力完成验证和研究。

### 3.6 技能与命令系统

`skills/` 下已经包含：

- `using-superpowers`
- `brainstorming`
- `writing-plans`
- `systematic-debugging`
- `verification-before-completion`
- `subagent-driven-development`
- `task-creator`
- `vibe`
- `ux-design`
- 以及一组 document / image / frontend / review 相关技能

`commands/` 下则有面向 goal runner 与受管运行的入口，如：

- `goal`
- `goal-start`
- `goal-status`
- `goal-stop`
- `task`
- `task-list`
- `task-run`

### 3.7 自动循环与机械检查

脚本层当前至少覆盖：

- `scripts/goal-runner.py`：Plan -> Act -> Test -> Review -> Wrap-up 自主循环
- `scripts/loop-cron.sh`：循环调度
- `scripts/ai-governance-smoke-check.sh`：治理烟雾检查
- `scripts/ai-trigger-check.sh`：触发词检查
- `scripts/check-vibe-config-paths.py`：vibe 路径分类检查
- `scripts/gitignore-check.sh`：忽略项检查
- `scripts/plugin-status-check.sh`：运行时 plugin receipt 检查

## 4. 目录说明

仓库根目录里，最值得先理解的是这些路径：

- `AGENTS.md`：总入口
- `opencode.json`：主运行配置
- `plugins/`：运行时插件
- `rules/ai/`：正式规则
- `workflows/ai/`：执行流程
- `references/ai/`：参考锚点
- `skills/`：技能库
- `commands/`：命令入口
- `scripts/`：自动化与检查脚本
- `templates/`：模板
- `docs/requirements/`：governed requirement 真值面
- `docs/plans/`：governed execution plan 真值面
- `docs/superpowers/specs/`：非 vibe 路径的手工 spec
- `docs/superpowers/plans/`：非 vibe 路径的手工 plan
- `provider-secrets.env`：provider / MCP 密钥集中管理

## 5. 如何配置

### 5.1 主配置文件

主配置入口是：

- `~/.config/opencode/opencode.json`

这里定义：

- provider
- model / small_model
- MCP server
- agent
- command
- plugin
- instruction 注入路径

修改这类配置后，通常需要重启 OpenCode 才会真正生效。

### 5.2 密钥与环境变量

敏感值默认不直接写进 `opencode.json`，而是通过 `{env:VAR}` 引用。

当前统一入口是：

- `~/.config/opencode/provider-secrets.env`

这个文件由：

- `~/.zshrc`

在 shell 启动时显式 `source`。

当前已在这里统一管理的变量包括：

- `DEEPSEEK_API_KEY`
- `OPENAI_API_KEY`
- `MIMO_API_KEY`
- `FASTAICODE_API_KEY`
- `BRAVE_API_KEY`

如果你要新增一个新的 provider 或 MCP 凭据，推荐步骤是：

1. 在 `provider-secrets.env` 新增 `export XXX=...`
2. 在 `opencode.json` 使用 `{env:XXX}` 引用
3. 重新打开 shell 或重启 OpenCode

### 5.3 添加或修改 provider

做法通常是：

1. 在 `opencode.json.provider` 下新增 provider 定义
2. 选定对应 `npm` 适配器或兼容协议
3. 使用 `{env:VAR}` 管理密钥
4. 视情况给出 `whitelist`、模型别名或 agent / command 入口

如果 provider 只兼容 `chat/completions` 而上游客户端需要 `responses`，不要假设它天然兼容，先做协议级验证。

### 5.4 添加 MCP

在 `opencode.json.mcp` 下声明即可，常见字段包括：

- `type: local | remote`
- `command`
- `url`
- `environment`
- `enabled`
- `timeout`

带认证的 MCP 优先也走 `{env:VAR}`。

### 5.5 添加 skill / agent / command

- skill：放到 `skills/<name>/SKILL.md`
- agent：放到 `agents/<name>.md` 或写进 `opencode.json.agent`
- command：放到 `commands/<name>.md` 或写进 `opencode.json.command`

如果一个入口是否会被当前运行面自动加载还没有运行证据，优先采用 `opencode.json` 的显式接线面。

## 6. 如何使用这套治理系统

一个典型任务的执行路径通常是：

1. 入口层根据 `AGENTS.md` 和 `rules/ai/routing-rules.md` 选路
2. 读取 `CURRENT_TASK.md`、必要的 `DECISIONS.md` / `AI_GUIDE.md`
3. 按任务类型进入对应 workflow 或 skill
4. 在运行层调用 provider、MCP、脚本与工具
5. 完成前跑验证、做闭环、判断是否需要 AAR / handoff

如果是治理系统本身的修改，完成前还要额外跑治理一致性检查。

## 7. 推荐验证命令

### 文件级与治理级检查

```bash
python3 -m json.tool ~/.config/opencode/opencode.json
bash ~/.config/opencode/scripts/ai-governance-smoke-check.sh
bash ~/.config/opencode/scripts/ai-trigger-check.sh
```

### 运行时最小验证

```bash
opencode run "Reply with exactly OK" --model deepseek/deepseek-v4-pro
```

如果改的是需要 reload / restart 的配置，不要把“文件已改”当成“运行面已生效”。

## 8. 当前已知边界

- 这套治理系统已经有事件级运行时护栏，但不等于 token 预算硬门禁。
- 某些运行面配置改动必须重启 OpenCode 才会生效。
- provider 兼容性不能只看名字，必须看实际协议面，例如 `responses` 与 `chat/completions` 的差异。
- `CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md` 是治理状态面，不应替代 git 历史。

## 9. 最小上手路径

如果你第一次接手这个仓，建议按这个顺序看：

1. `AGENTS.md`
2. `opencode.json`
3. `rules/ai/routing-rules.md`
4. `rules/ai/verification-rules.md`
5. `CURRENT_TASK.md`
6. `DECISIONS.md`
7. `AI_GUIDE.md`
8. `scripts/ai-governance-smoke-check.sh`

这样能先搞清楚：系统如何路由、如何验证、当前任务是什么、哪些决策已经固定、以及有哪些机械检查兜底。
