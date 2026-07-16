## 修复与审查工作流

1. 先读 `AGENTS.md` 和 `rules/ai/routing-rules.md`
2. 修复路径：先走 `systematic-debugging`，检查相关代码、测试和现有行为证据，只做最小正确修改
3. 审查路径：优先找 bug、行为回归、测试缺口和证明不足；有发现时先列 findings 按严重度排序，无发现时明确写"未发现问题"并补充假设和残留风险
4. 如果结论依赖类型、语法、配置告警或定义跳转，先补原生 LSP 诊断或查询证据；如果依赖跨文件语义关系，先补 `serena` 证据
5. 运行与任务匹配的验证
6. 如果修复或审查对象属于高频治理变更，按 `references/ai/verification-templates.md` 选对应模板组织证据
7. 宣称完成前，按 `rules/ai/task-closure.md` 走闭环
