## AI 验证模板

仅收录高频治理场景的紧凑验证模板；详细规则仍以 `rules/ai/verification-rules.md` 为准。

### 1. Governance-doc changes

- 适用：`AGENTS.md`、`rules/ai/*`、`workflows/ai/*`、`references/ai/*`、状态文件
- 证据块：
  - 变更范围：
  - 实际核对文件：
  - 路径存在性检查：通过 / 失败
  - `workflows/ai/check-governance-consistency.md`：已执行 / 不适用
  - 是否发现冲突或第二真相面：无 / 有（说明）

### 2. Serena / LSP / MCP config changes

- 适用：`serena`、原生 LSP、MCP、`opencode.json` 等运行时配置面
- 证据块：
  - 变更的配置面：
  - 需要的 refresh / reactivate / restart：
  - 实际执行动作：
  - refresh 后重新采集的运行证据：
  - 未完成项 / 限制：无 / 有（说明）

### 3. Subagent routing / prompt changes

- 适用：`workflows/ai/subagent-routing.md`、subagent dispatch 结构、相关 agent prompt
- 证据块：
  - 核对的 routing / prompt 文件：
  - 是否仍对齐共享模板 `Role / Goal / Scope / Constraints / Inputs / Expected Output / Verification`：是 / 否
  - 是否引入第二套 prompt 结构：否 / 是（说明）
  - 相关运行面或引用面是否同步：是 / 否（说明）

### 4. Command-template or agent-prompt changes

- 适用：命令模板、agent prompt、运行时 prompt 包装层
- 证据块：
  - 核对文件：
  - 静态文本已对齐的规则 / reference：
  - 是否需要 runtime refresh：否 / 是（说明）
  - 如果需要 refresh，refresh 后证据：
  - 是否存在遗留旧模板或旧措辞：无 / 有（说明）

### 5. Session-budget or token-reminder changes

- 适用：会话 token 阈值、长会话提醒、开新会话规则、压缩后重路由要求
- 证据块：
  - 阈值设置：`100000` 预警 / `150000` 强提醒 / 其他（说明）
  - 核对的入口与规则文件：
  - 是否已覆盖“新任务重路由”与“长会话强提醒”两类场景：是 / 否
  - 当前 host 是否暴露可直接读取的实时 token 计数：是 / 否
  - 如果否，当前结论类型：治理约束已接入 / 已建立真实运行时门禁
  - 是否发现第二套阈值、旧提醒文案或冲突表述：无 / 有（说明）

### 6. 双模型交叉验证模板（高风险改动）

- 适用：高风险改动需要两个模型独立 review 后对比结论
- 证据块：
  - 主审模型（默认 review 模型）：
  - 第二意见模型（`deepseek-pro`）：
  - 一致结论：共识（记录）
  - 不一致结论：必须逐条标注并显式调查
  - 最终风险判断：approve / request-changes
  - 命令入口：`/xreview`

### 7. 浏览器/MCP 运行面验证模板（Playwright 等）

- 适用：Playwright / lightpanda 等浏览器 MCP 的可用性与截图链路验证
- 证据块：
  - MCP 配置面：`opencode.json` `mcp.*`
  - 浏览器二进制安装：`npx playwright install chromium`（结果）
  - 系统依赖 `install-deps`：已执行 / 需 sudo 待办 / 不适用
  - MCP 客户端是否被发现并创建（重启后日志）：是 / 否
  - 截图是否回传模型可观看：是 / 否 / 未确认
  - 运行证据采集时间：
