## 审查工作流

1. 先读 `AGENTS.md` 和 `rules/ai/routing-rules.md`
2. 优先找 bug、行为回归、测试缺口和证明不足
3. 如果审查结论依赖诊断或符号关系，补充原生 LSP 或 `serena` 证据，再下结论
4. 如果有发现，先列 findings，按严重度排序
5. findings 后再补充必要的假设、残留风险和简短总结
6. 如果没有发现，明确写“未发现问题”，再说明残留风险或测试空白
7. 如果审查对象属于高频治理变更，验证证据优先引用 `references/ai/verification-templates.md` 的对应模板，避免在 review 结果里再展开第二套检查单
