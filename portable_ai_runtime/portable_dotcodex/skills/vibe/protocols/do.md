## Do Protocol

本文件描述 `vibe` 的实现、调试与执行阶段约束。

### During `plan_execute`

- 只做冻结计划允许的修改
- 子任务可委派，但最终整合、最终验证、最终结论仍由 root lane 负责
- specialist usage 必须保持有界，不得另起第二套计划面

### Verification Expectations

- 每个重要执行单元都应留下可复核证据
- 声称修复、通过、完成前，先回到 `verification-before-completion` 的证据要求
- 如变更需要 restart / refresh 才会真实生效，不把静态文件修改当作运行时完成

### Failure Handling

- 遇到阻塞时优先报告阻塞来源与影响范围
- 不用“以后再补验证”替代当前证据缺口
