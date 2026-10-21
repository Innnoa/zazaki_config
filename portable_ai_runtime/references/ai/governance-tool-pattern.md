## 治理工具命令成套模式（governance-tool pattern）

Governance tool 命令按三件套组织：

1. `scripts/<name>.sh` — 幂等 checker/applier：exact-match 判断 + separator comment + 幂等 report（重复运行结果一致，可安全重跑）。
2. `commands/<name>.md` — YAML frontmatter 描述命令的用法与参数。
3. `opencode.json` command registration — template 形式调用 bash 脚本，注册为可用命令。

先例：`scripts/ai-governance-smoke-check.sh`、`scripts/test-trigger.sh`、`scripts/ai-trigger-check.sh`、`scripts/regression-test.sh`。新增治理检查命令时复用该成套结构，保证幂等、可发现、可注册。

脚本的退出码与输出约定见 `references/ai/script-error-handling.md`。
