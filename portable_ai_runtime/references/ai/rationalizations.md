# Rationalizations to Reject

> **触发频率：低** — 此文件为人工审查参考，AI 日常任务路由上不自动激活。
> 实际反制措施的执行依靠 `AGENTS.md` 的 Red Flags 块和 `plugins/session-governance/index.ts` 的权限升级 hook，
> 不依赖 AI 阅读本文件后启动"反借口自检"。

Agent 在压力下常用来绕过流程的真实说辞。只从真实失败里收集，不凭空扩写。

## 路由与纪律

| 借口 | 来源 | 反制 |
|------|------|------|
| "这次只是小补充，不算新任务" | AGENTS.md | 任何涉及文件修改都是新任务，必须重读入口 |
| "我刚刚已经读过这些文件" | AGENTS.md | 同会话第 N 轮也必须重读，不能凭记忆 |
| "先做一下，最后再补路由" | AGENTS.md | 没有路由就不知道规则，不知道规则就会出错 |
| "压缩后应该还记得" | AGENTS.md | 压缩会丢上下文，靠残留记忆必然出错 |
| "文档里写了阈值，就等于已经有运行时门禁" | AGENTS.md | 文档规则 ≠ 代码执行，不要混淆 |
| "reference 里有就够了，不用放到入口或正式规则" | AGENTS.md | 不放在任务路径上的规则等于不存在 |

## 修复与调试

| 借口 | 来源 | 反制 |
|------|------|------|
| "Quick fix for now, investigate later" | systematic-debugging | 先修后查 = 必然不查。先查后修 |
| "Just try changing X and see if it works" | systematic-debugging | 猜不是调试。形成假设，测试验证 |
| "Add multiple changes, run tests" | systematic-debugging | 多变量无法隔离原因。一次一个 |
| "Skip the test, I'll manually verify" | systematic-debugging | 手动验证不可复现。必须有自动化测试 |
| "It's probably X, let me fix that" | systematic-debugging | 概率不是证据。收集证据确认再修 |
| "I don't fully understand but this might work" | systematic-debugging | 不理解就修 = 引入新 bug。先理解 |
| "One more fix attempt" (already 2+) | systematic-debugging | 3 次失败 = 架构问题，不是调试问题 |
| "这个改动太小了，不用走 systematic-debugging" | fix-and-review | 小 bug 也有根因。缩小范围不等于跳过流程 |
| "一眼就能看出问题，直接修" | fix-and-review | 看出来的不是根因，是症状 |
| "顺便改一下这个不相关的小问题" | fix-and-review | 超出范围的改动破坏可追溯性 |

## 代码审查

| 借口 | 来源 | 反制 |
|------|------|------|
| "审查通过了，AAR 可以跳过" | fix-and-review | AAR 是交付的一部分，不是可选项 |

## 任务闭环

| 借口 | 来源 | 反制 |
|------|------|------|
| "这次 AAR 就算了" | task-closure | AAR 四问必须逐条回答，不能跳过 |
| "这次没有新经验"（未经检查就结论） | task-closure | 必须先检查再下结论，不能预设 |
| "文件已经改好了，不需要跑验证" | verification-rules | 文件改了 ≠ 行为正确。必须跑验证 |

## 使用规则

- 新借口出现时先记录到本表，再更新对应 workflow 的 Red Flags 引用
- 借口必须来自真实发生的会话或 AAR，禁止虚构
- 每条借口必须有具体反制措施，不能只说"不允许"
