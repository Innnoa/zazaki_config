## AI 反模式

只记录已经真实发生过、并且至少造成以下一种后果的反模式：

- 路由漂移
- 质量下降
- 验证缺失
- 写入位置错误
- 执行结果与用户目标错位

边界：anti-patterns 记录 Agent 行为层面的错误模式（"不该这样做"）。
gotchas 记录系统运行时的实际行为坑点（"踩到就会出问题"）。
同一结论只在一个文件做主落点；两者有交叉时，以本文件为行为维度主落点。

## 行为反模式

- 把路由细节、记录位置和读取顺序同时写进 `AGENTS.md` 与下层规则文件，会快速制造双重维护和漂移。
- 把同一条治理结论分别写进 `AGENTS.md`、`rules/ai/*`、`references/ai/*` 和状态文件，会让后续修改时无法判断哪一层才是主落点。
- 把"token 预算提醒"写成纯 reference 但不放入口或正式规则，等于只存了知识，没把它接到真实任务路径上。
- 把"长会话提醒"误写成"运行时已经自动拦截"，但没有 hook 或 host 证据，这属于把治理约束伪装成运行时能力。
- 把会话叙事、调试过程或一次性口头说明写进 reference，会让 reference 变成日志仓而不是稳定知识面。

## before/after 示例

### 反模式 1：过度修改

用户要求"修复空 email 导致崩溃"。Agent 顺手加了 docstring、更强的邮箱格式校验、username 校验。

```
❌ BAD — 超出请求范围
用户: "用户注册时 email 为空会 crash"
Agent: "我来修。顺便加了 email 格式校验、username 长度校验、手机号格式校验，
        还重写了错误消息、加了 i18n key、抽了公共校验函数。"

✅ GOOD — 只做最小修复
用户: "用户注册时 email 为空会 crash"
Agent: "根因是 validateUser() 在 email=null 时未做空值 guard。
        最小修复：在 validateUser() 入口加 if (!email) return false。
        验证：补充了 email=null 的测试用例，全部通过。"
```

### 反模式 2：跳过路由重读

同一会话的第 N 轮新任务，Agent 凭记忆直接工作，没重读入口文件。

```
❌ BAD — 跳过入口重读
用户 (会话第 5 轮): "帮我把 API 的错误处理统一一下"
Agent: "好的，我来改所有 controller..."  ← 没读 AGENTS.md，没匹配路由

✅ GOOD — 每次重读入口
用户 (会话第 5 轮): "帮我把 API 的错误处理统一一下"
Agent: [先读 AGENTS.md → 匹配 routing-rules.md → 判断属于 feature change → brainstorming]
       "这是个行为修改，我先走 brainstorming 确认设计..."
```

### 反模式 3：跳过验证

Agent 改完文件就宣称完成，没有实际运行验证。

```
❌ BAD — 文件改好就算完成
Agent: "我已经修改了 opencode.json，新增了 provider 配置。
       任务完成。"
       ↑ 没有运行 json lint，没有跑 smoke-check

✅ GOOD — 验证证据先于完成声明
Agent: "已修改 opencode.json。验证：
       1. python3 -m json.tool opencode.json → 语法通过
       2. bash scripts/ai-governance-smoke-check.sh → 0 errors
       3. bash scripts/ai-trigger-check.sh → 通过
       任务完成。"
```
