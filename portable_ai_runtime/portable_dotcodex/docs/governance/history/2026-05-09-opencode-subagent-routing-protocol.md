# OpenCode Subagent Routing Protocol Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把新的“串行 / 并行 subagent 派发前路由协议”融入当前 AI 治理系统，并保持薄壳与下沉细则风格一致。

**Architecture:** 该协议不做成独立 skill，也不塞回 `AGENTS.md` 大段正文，而是落成独立 workflow，并由 `routing-rules.md` 与 `AGENTS.md` 做轻接线。这样可以把“是否派发 subagent、派发时串行还是并行”的判断，放在一个正式且可复用的执行协议里，同时避免与现有 skill、原则层和顶层薄壳职责冲突。

**Tech Stack:** Markdown 文档、现有 `rules/ai/`、`workflows/ai/`、`AGENTS.md`

---

### Task 1: Add The Subagent Routing Workflow

**Files:**
- Create: `workflows/ai/subagent-routing.md`

- [ ] **Step 1: Create `workflows/ai/subagent-routing.md` with the new protocol content**

Create a workflow file that includes:

- 协议作用：主协调 agent 在决定是否派发 subagent 前必须先执行
- 决策原则 1-7
- 判断表 6 项
- 固定输出格式：

```text
Decision: Serial | Parallel
Reasoning:
- ...
Plan:
- ...
Guardrails:
- ...
```

- 执行要求：
  - 并行时每个 subagent 只拿最小上下文
  - 避免多个 subagent 同时修改同一文件
  - 主 agent 不外包最终判断
  - 所有结果返回后，主 agent 必须统一审查、去重、整合、验证

- [ ] **Step 2: Verify the workflow contains the required fixed output format markers**

Run: `rg -n "Decision: Serial \| Parallel|Reasoning:|Plan:|Guardrails:" "/home/zazaki/.config/opencode/workflows/ai/subagent-routing.md"`
Expected: all four output-format markers are present.

### Task 2: Connect The Protocol Into Routing And AGENTS

**Files:**
- Modify: `rules/ai/routing-rules.md`
- Modify: `AGENTS.md`

- [ ] **Step 1: Add a routing note to `rules/ai/routing-rules.md`**

Add a short bullet under `### 路由检查`:

```md
- 准备使用多 agent / subagent 前，先执行 `workflows/ai/subagent-routing.md`；信息不足时先串行探索，再决定是否并行。
```

- [ ] **Step 2: Add a thin-shell entry to `AGENTS.md`**

Add one short bullet under `## 6. 治理入口`:

```md
- 并行 / 串行派发协议见 `workflows/ai/subagent-routing.md`
```

- [ ] **Step 3: Verify both entry points exist**

Run: `rg -n "subagent-routing\.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/AGENTS.md"`
Expected: both files contain the new reference.

### Task 3: Add A Minimal Anchor And Non-Conflict Note

**Files:**
- Modify: `AI_GUIDE.md`
- Modify: `rules/ai/governance-principles.md`

- [ ] **Step 1: Add an AI_GUIDE anchor**

Append a short anchor section:

```md
### 2026-05-09 - Subagent routing protocol added

- 已建立 `workflows/ai/subagent-routing.md`
- 多 agent / subagent 派发前，先判断串行或并行
- 最终汇总、验证与结论输出仍由主 agent 串行完成
```

- [ ] **Step 2: Add one non-conflict note to `governance-principles.md`**

Append one short bullet under `### 1. 路由单一权威源`:

```md
- 是否派发 subagent、以及串行还是并行，属于执行协议判断，正式协议见 `workflows/ai/subagent-routing.md`。
```

- [ ] **Step 3: Verify the anchor and non-conflict note exist**

Run: `rg -n "Subagent routing protocol added|最终汇总、验证与结论输出仍由主 agent 串行完成|串行还是并行" "/home/zazaki/.config/opencode/AI_GUIDE.md" "/home/zazaki/.config/opencode/rules/ai/governance-principles.md"`
Expected: all key phrases are present.

### Task 4: Validate The Integrated Protocol

**Files:**
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` only if a clear mismatch remains after implementation

- [ ] **Step 1: Check for unresolved markers in touched files**

Run: `rg -n "TODO|TBD|FILL" "/home/zazaki/.config/opencode/workflows/ai/subagent-routing.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/AGENTS.md" "/home/zazaki/.config/opencode/AI_GUIDE.md" "/home/zazaki/.config/opencode/rules/ai/governance-principles.md"`
Expected: no matches.

- [ ] **Step 2: Check that the protocol is connected but not over-promoted**

Run: `rg -n "subagent-routing\.md|串行探索|最终汇总、验证与结论输出仍由主 agent 串行完成" "/home/zazaki/.config/opencode/workflows/ai/subagent-routing.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/AGENTS.md" "/home/zazaki/.config/opencode/AI_GUIDE.md" "/home/zazaki/.config/opencode/rules/ai/governance-principles.md"`
Expected: the workflow is referenced from AGENTS and routing-rules, and summarized lightly elsewhere.

- [ ] **Step 3: Record validation outcome in the final summary**

Include in final report:

```text
Validation run:
- unresolved marker scan: pass/fail
- workflow output-format check: pass/fail
- AGENTS/routing entry check: pass/fail
- anchor/principles note check: pass/fail
```

- [ ] **Step 4: Commit only if this directory becomes a git repository before execution time**

```bash
git add workflows/ai/subagent-routing.md rules/ai/routing-rules.md AGENTS.md AI_GUIDE.md rules/ai/governance-principles.md docs/superpowers/plans/2026-05-09-opencode-subagent-routing-protocol.md
git commit -m "docs: add subagent routing protocol"
```

If the directory is still not a git repository, skip commit and state that commit was not possible in the execution summary.
