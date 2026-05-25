## 修 Bug 工作流

1. 先读 `AGENTS.md` 和 `rules/ai/routing-rules.md`
2. 在提出修复方案前，先走 `systematic-debugging`
3. 检查相关代码、测试和现有行为证据
4. 如果 bug 与类型、语法、配置告警或定义跳转有关，先补原生 LSP 诊断或查询证据；如果 bug 与跨文件语义关系有关，先补 `serena` 证据
5. 只做最小正确修改，避免顺手扩需求
6. 运行与任务匹配的验证；若修复同时改到治理层或运行配置，按 `references/ai/verification-templates.md` 选对应高频模板组织证据
7. 宣称完成前，按 `rules/ai/task-closure.md` 走闭环
