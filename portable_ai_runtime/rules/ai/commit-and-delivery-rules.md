## 提交与交付规则

### 作用

定义提交前的审查门禁（repo-audit、pre-commit hook）和交付时的说明要求，防止 AI 产物进入公开仓库。

### 提交前审查

- 准备 `git commit`、提交说明、暂存区整理或判断“是否可提交”前，必须先运行 `repo-audit`。
- 优先使用本地 MCP `audit_repo_before_commit`。
- 若返回阻断问题，先说明问题路径、类型和建议处理方式，不得继续提交。
- 不得把构建、缓存、依赖、AI 运行产物、脏文件或未确认的未跟踪文件加入公开提交。
- `repo-audit` 会通过两个途径拦截 AI 产物：1) 静态路径匹配（如 `CURRENT_TASK.md`、`DECISIONS.md`、`handoff/` 等）；2) 文件首行的 `<!-- ai-generated` 动态标记检测。凡是带此标记的文件，即使不在静态列表中也会被阻断。
- 可通过 `ln -s ~/.config/opencode/scripts/git-hooks/pre-commit .git/hooks/pre-commit` 安装预提交钩子，实现硬门禁：任何带 `<!-- ai-generated` 标记或在静态 AI 产物路径列表中的文件进入暂存区时，git commit 会被直接拒绝。
- 当 AI 在新项目初始化 git 仓库（`git init`）或首次进入已有 git 仓库开始工作时，应主动检查并安装该 pre-commit hook。如果 `.git/hooks/pre-commit` 不存在或不指向当前版本的 hook，执行安装命令。

检验：在宣称"可以提交"之前，`repo-audit` 是否已通过？有没有阻断问题未处理？暂存区里是否有不应提交的 AI 产物？

### 交付要求

- 说明改了什么。
- 说明为什么这样改。
- 说明实际执行了哪些验证。
- 说明残留风险、未覆盖项或无法完成的部分。
- 若任务走了 `vibe` 路径，还应说明 requirement、plan 和 runtime receipt 的落点。

### 质量要求

- 不得硬编码 secrets。
- 所有输入应做必要校验。
- 应避免注入风险。
- 相关输出应处理编码或清洗。
- 错误信息不应泄露敏感上下文。
- 非 trivial 逻辑尽量保持有意义验证覆盖。
- 在可行时优先采用最小通过改动。
- 在声称完成前必须有验证证据。

### 检验句

问自己：`在宣称"可以提交"之前，repo-audit 是否已通过？有没有阻断问题未处理？暂存区里是否有不应提交的 AI 产物？`
