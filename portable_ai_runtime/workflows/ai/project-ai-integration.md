# 个人项目接入 AI 治理流程

把个人项目（`~/Projects/` 下等）的能力接入 AI 治理系统，让 AI 可以直接调用。本流程覆盖"评估哪些项目适合接入 + 以什么方式接入 + 如何验证"。

## 触发条件

- 用户要求"把项目接入 AI / 让 AI 拥有该项目能力 / 调查哪些项目适合接入"
- 新增个人工具后希望 AI 可用

## 步骤

### 1. 侦察（每项目产出压缩条目）

技术栈、核心功能、对外接口（CLI 子命令/API/服务）、治理痕迹（AGENTS.md、AI_GUIDE.md、CURRENT_TASK.md、DECISIONS.md、GOAL_STATE.json、codemap.md 等治理文件，以及 MCP server）、构建与运行方式。多个项目时用 explorer 并行分租。

### 2. 可调用性分档

| 档 | 特征 | 示例 | 处置 |
|---|---|---|---|
| 高 | 稳定 CLI + JSON/结构化输出 | ssh/scp/sql/ping/trans/tokenizer/grab | 接入 |
| 中 | TUI 但库层可复用 | git/top/regex | 低优先，视成本 |
| 低 | 纯展示/演示、无参数接口、与通用工具重叠 | fetch/Ray_Tracer/Tasks_View | 不接入 |
| 服务型 | 需守护进程/特权端口 | dns/chat-dialogue | command + 启停纪律 |

已接入的 MCP 项目（repo-audit/wechat/rag 等）不重复评估，只确认接线状态。

### 3. 接入方式（按成本递增选）

- **command 模板**（`commands/*.md`）：有稳定 CLI 的默认选择；模板含用法要点 + 注意（权限/secrets/stub）
- **skill**：有固定工作流时（如服务启停、抓包流程）
- **MCP**：高频结构化交互时；采用"核心逻辑纯函数 + 薄 stdio JSON-RPC 壳"模式（先例：zazaki_mcp_repo-audit）

### 4. 实施纪律

- **写 command 前必须实际验证 CLI 用法**（`--help`/`--version`/样例执行），禁止凭 README 或记忆猜测参数
- **补 AGENTS.md**：目标项目有 codemap.md 时用"Repository Map 指向式"先例（zazaki_sql/ping/trans）；无 codemap 时写自包含轻量地图（用途 + 目录 + 构建/测试/运行命令 + 注意），不要指向不存在的文件
- **secrets**：配置含 token 时必须确认 `.gitignore` 覆盖，并采用 `${ENV}` 占位符或纪律提醒；AI 输出/交接不得粘贴明文 token
- **聚合索引**：接入后更新 `commands/zazaki-tools.md` 能力清单

### 5. 验证（治理变更门禁）

- 引用的 CLI 冒烟测试（每个 command 至少验证一次实际可执行）
- `bash scripts/ai-governance-smoke-check.sh` → PASS
- `bash scripts/test-trigger.sh` → PASS

### 6. AAR

按 `rules/ai/task-closure.md` 跑 AAR 四问；有高价值坑点/模式写入 `~/docs/ai/AAR_his/AAR_INBOX.md`。

## 检验句

每个 command 模板里的命令是否都实际验证过？引用的文件路径是否存在？secrets 是否被 gitignore 且未被写入任何交付物？
