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
   - `Common Tasks`
   - `Auto-Triggers`
   - `Red Flags - STOP`
   - `Known Gotchas`
2. `opencode.json` 的 `instructions` 是否同时覆盖：
   - `~/.config/opencode/rules/*.md`
   - `~/.config/opencode/rules/ai/*.md`
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

### 通过标准

- 所有入口块存在
- `rules/ai/*.md` 已注入
- 会话预算阈值无冲突
- 没有把“治理接入”误报成“运行时自动强制”
