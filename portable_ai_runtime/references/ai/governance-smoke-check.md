## Governance Smoke Check

### 作用

提供一份轻量的治理自检清单，专门抓“规则写了但不激活”这类遗忘型错误。

### 适用场景

- 编辑 `AGENTS.md` 后
- 编辑 `opencode.json` 后
- 编辑会话纪律、token 预算或触发规则后
- 宣称治理迁移或治理接线完成前

### 检查项

1. `AGENTS.md` 是否仍保留以下入口块：
   - `Always Read`
   - `Session Discipline`
   - `Quick Routing`
   - `Auto-Triggers`
   - `Red Flags - STOP`
   - `Known Gotchas`
2. `opencode.json` 的 `instructions` 是否覆盖薄壳：
   - `~/.config/opencode/rules/ai/routing-rules.md`（强制注入的路由权威；`AGENTS.md` 由 opencode 自动加载）
   - 不得再使用 `rules/ai/*.md` 全量通配，否则壳重新变厚
3. `100000` 与 `150000` 阈值是否只保留一套正式定义，没有冲突版本
4. 会话预算规则是否至少在以下两层出现锚点：
   - 顶层入口
   - 正式规则
   - reference / 验证模板
5. 是否存在把治理约束误写成运行时硬门禁的表述

### 建议执行方式

- 文件级人工核对
- `opencode.json` 执行一次 JSON 语法校验
- 必要时用内容搜索确认阈值和固定提醒文案只有一套

### 实验性插件与 Hook 验证

`plugins/session-governance/index.ts` 通过以下 hook 实施运行时治理：

- `ctx.session.hook("context", ...)`：在每次系统提示中注入 Governance Shell 和 Session Budget 块
- `ctx.session.hook("compaction", ...)`：在上下文压缩时保留 CURRENT_TASK、DECISIONS 和 session-budget-rules
- `ctx.permission.hook("evaluate", ...)`：对治理文件编辑做权限升级和文件尺寸硬拒绝

验证步骤（需要重启当前 OpenCode 会话后才能完整验证）：

1. 重启 OpenCode 后，在新会话中检查系统提示是否包含 `Governance Shell` 和 `Session Budget` 块
2. 触发一次上下文压缩（长对话或手动 compact），检查压缩后是否仍保留 `Governance Context To Preserve` 块
3. 尝试编辑一个超过 350 行、25KB 或单行 500 字符的治理文件，确认被拒绝并显示尺寸超限消息
4. 编辑一个正常大小的治理文件（如 `rules/ai/task-closure.md`），确认系统弹出权限确认而不是静默允许

当前会话内可通过以下方式做静态验证：

静态验证可通过 `scripts/plugin-status-check.sh` 执行。

### `plugins/verify-gates/index.ts` 范围注记（纯静态验证）

`plugins/verify-gates/index.ts` 只对治理文件做静态验证，不执行任何浏览器级动作：

- 对 `VERIFY_TARGETS` 覆盖范围内的 `.json` 文件做 JSON 可解析性校验
- 对治理类 `.md` 文件做行数守卫（超过 350 行给出拆分 WARN）
- 软门禁：仅在工具输出上追加注记，不抛错、不拒绝任何编辑
- 它**从不**触发页面图像采集，也**从不**探测本地 dev-server 端口；此类分支（原 Branch B 的图像采集 / 端口探测路径）已于 2026-09-02 移除，该插件当前没有任何浏览器自动化或本地端口探测能力

该插件的文件头行为注记是本节的上游事实源；运行时治理 hook 见上方 `plugins/session-governance/index.ts` 段落。

### 通过标准

- 所有入口块存在
- `rules/ai/routing-rules.md` 已注入（薄壳）
- 会话预算阈值无冲突
- 没有把“治理接入”误报成“运行时自动强制”
