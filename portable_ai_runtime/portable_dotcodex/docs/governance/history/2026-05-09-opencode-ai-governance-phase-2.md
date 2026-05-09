# OpenCode AI Governance Phase 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 收紧治理层任务路由规则，并在当前 `/home/zazaki/.config/opencode` 目录中直接建立可用的状态文件体系。

**Architecture:** 本阶段不改动 MCP 配置和现有 skill 文件本体，而是在治理层继续补两类能力：一类是把 `rules/ai/routing-rules.md` 从“可用”收紧到“更明确可判定”；另一类是在配置目录中真实创建 `CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md` 与 `handoff/`，让 Phase 1 的记录规则有实际落点可用。

**Tech Stack:** Markdown 文档、OpenCode 配置目录结构、现有治理规则文件

---

### Task 1: Tighten Routing Rules For Mandatory Paths

**Files:**
- Modify: `rules/ai/routing-rules.md`
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md`

- [ ] **Step 1: Read the current routing rules and design spec routing section**

Run: `rg -n "Always Read|Common Tasks|vibe|writing-plans|CURRENT_TASK|DECISIONS" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md"`
Expected: the current route definitions are shown from both files.

- [ ] **Step 2: Tighten `Always Read` conditions in `rules/ai/routing-rules.md`**

Replace the current `Always Read` block with content that makes the read conditions more explicit:

```md
### Always Read

1. 总是先读 `AGENTS.md`
2. 如果当前目录已经建立 `CURRENT_TASK.md`，并且任务不是纯信息问答，则读取它
3. 如果任务会复用既有技术取舍、约束、迁移背景或历史决定，则读取 `DECISIONS.md`
4. 如果任务是对当前配置仓本身做治理修改，再补读相关 `rules/ai/` 和 `workflows/ai/`
```

- [ ] **Step 3: Tighten `Common Tasks` conditions in `rules/ai/routing-rules.md`**

Replace the current `Common Tasks` block with the following explicit routing rules:

```md
### Common Tasks

- 修 bug：先用 `systematic-debugging`，再按 `workflows/ai/fix-bug.md` 执行
- 实现功能：先用 `brainstorming`；如果实现步骤达到 3 步及以上、涉及多文件修改、或需要跨轮执行，再用 `writing-plans`，随后按 `workflows/ai/implement-feature.md` 执行
- 规划或拆实施路径：按 `workflows/ai/plan.md` 执行
- 代码审查：按 `workflows/ai/review.md` 执行
- 复杂多文件、跨轮跟踪、需要冻结 requirement / plan、或需要更强验证闭环的任务：必须走 `vibe`
- 多子任务且相互独立的任务：优先 `subagent-driven-development`，如果同时满足 `vibe` 条件，则优先 `vibe`
- 提交前完成确认：应用 `rules/ai/verification-rules.md`，并在需要判断“是否可提交”时先运行 `repo-audit`
- 未分类任务：先应用 Always Read，再选择最接近的 workflow，并在汇报里明确说明匹配原因
```

- [ ] **Step 4: Add a short decision note under `Routing Checks` for ambiguous routing**

Append this bullet to the existing `### 路由检查` section:

```md
- 如果一个任务同时命中多个路径，优先顺序为：安全/阻断风险 > `vibe` 受管运行时 > 明确 workflow > 兜底路径。
```

- [ ] **Step 5: Sync the design spec routing text with the tightened rules**

Update the routing section in `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` so that it matches the tightened definitions above, especially:

- `CURRENT_TASK.md` 的读取条件
- `DECISIONS.md` 的读取条件
- `writing-plans` 的触发条件
- `vibe` 的“必须走”条件
- `subagent-driven-development` 与 `vibe` 的优先关系

- [ ] **Step 6: Verify the routing rules contain the tightened conditions**

Run: `rg -n "必须走 `vibe`|3 步及以上|CURRENT_TASK.md|DECISIONS.md|repo-audit|subagent-driven-development" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md"`
Expected: all tightened routing phrases are present.

### Task 2: Create Real State Files In The OpenCode Config Directory

**Files:**
- Create: `CURRENT_TASK.md`
- Create: `DECISIONS.md`
- Create: `AI_GUIDE.md`
- Create: `handoff/README.md`

- [ ] **Step 1: Verify the state files do not already exist in the config directory**

Run: `ls "/home/zazaki/.config/opencode"`
Expected: no `CURRENT_TASK.md`, `DECISIONS.md`, or `AI_GUIDE.md` file is listed yet.

- [ ] **Step 2: Create `CURRENT_TASK.md` with an actively usable structure**

Create this exact content:

```md
# CURRENT_TASK

## 当前目标

把 `/home/zazaki/.config/opencode` 的 AI 治理层从 Phase 1 推进到后续阶段，逐步形成稳定的任务路由、状态文件、闭环与经验沉淀机制。

## 当前范围

- 治理层目录：`rules/ai/`、`workflows/ai/`、`references/ai/`
- 顶层入口：`AGENTS.md`
- 设计与计划文档：`docs/superpowers/specs/`、`docs/superpowers/plans/`

## 当前验收

- 顶层入口能把任务路由到治理层文件
- 状态文件有清晰边界并可直接使用
- 后续治理工作可以继续在本目录内渐进推进

## 当前状态

- Phase 1 已完成：治理骨架、基础 workflow、治理入口已落地
- 下一步进入 Phase 2：收紧任务路由并建立真实状态文件

## 下一步

1. 收紧路由判定条件
2. 创建 `CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md`、`handoff/`
3. 继续把后续治理动作沉淀到这些文件
```

- [ ] **Step 3: Create `DECISIONS.md` with an initial decisions log structure**

Create this exact content:

```md
# DECISIONS

## 已记录决策

### 2026-05-09 - 治理层采用渐进式框架化

- 结论：不推翻现有 `AGENTS.md`、skills 和 MCP 配置，只在其上新增治理层目录与路由规则。
- 原因：当前环境已经具备较强基础设施，主要缺口在治理层而不是工具能力。
- 影响：后续治理工作优先通过 `rules/ai/`、`workflows/ai/`、`references/ai/` 扩展，而不是继续把细则堆回 `AGENTS.md`。

### 2026-05-09 - 复杂任务优先走 vibe

- 结论：复杂多文件、跨轮跟踪、需要冻结 requirement 或 plan、或需要更强验证闭环的任务，优先进入 `vibe` 路径。
- 原因：`vibe` 已是现有环境里最接近受管运行时的能力。
- 影响：普通任务继续走 `quick` 或明确 workflow，复杂任务避免在顶层自由漂移。
```

- [ ] **Step 4: Create `AI_GUIDE.md` with an audit/verification anchor structure**

Create this exact content:

```md
# AI_GUIDE

## 作用

记录项目级 AI 治理观察、关键验证锚点和跨轮增量，不记录敏感信息，不替代 git 历史。

## 当前锚点

### 2026-05-09 - Governance Phase 1 landed

- 已建立 `rules/ai/`、`workflows/ai/`、`references/ai/`
- `AGENTS.md` 已接入 `AI Governance Routing`
- 当前目录不是 git 仓库，因此提交级审计证据受限

## 增量记录规范

- 只记录项目级观察、关键验证结论和跨轮仍有价值的信息
- 不写原始会话日志
- 不写密码、令牌、密钥等敏感信息
```

- [ ] **Step 5: Create `handoff/README.md` with a handoff scope description**

Create this exact content:

```md
# handoff

此目录用于存放会话切换时的精简交接材料。

## 应该放什么

- 当前做到哪里
- 下一个执行者需要知道的最小上下文
- 尚未完成但已经确认的约束或风险

## 不应该放什么

- 冗长会话日志
- 可直接写进 `DECISIONS.md` 或 `AI_GUIDE.md` 的稳定内容
- 敏感信息
```

- [ ] **Step 6: Verify the new state files exist and are readable**

Run: `ls "/home/zazaki/.config/opencode" && ls "/home/zazaki/.config/opencode/handoff"`
Expected: `CURRENT_TASK.md`, `DECISIONS.md`, `AI_GUIDE.md`, and `handoff/README.md` are listed.

### Task 3: Connect The New State Files Back Into Governance Rules

**Files:**
- Modify: `rules/ai/recording-rules.md`
- Modify: `rules/ai/routing-rules.md`
- Modify: `AGENTS.md`

- [ ] **Step 1: Update `rules/ai/recording-rules.md` to state that the config directory now has real state files**

Add this short section after `### 记录位置`:

```md
### 当前配置目录状态

当前 `/home/zazaki/.config/opencode` 已直接建立：

- `CURRENT_TASK.md`
- `DECISIONS.md`
- `AI_GUIDE.md`
- `handoff/`

后续治理任务应优先使用这些真实落点，而不是继续停留在“规则存在但文件未落地”的状态。
```

- [ ] **Step 2: Update `rules/ai/routing-rules.md` to reflect that `CURRENT_TASK.md` is now expected to exist in this config directory**

Append this bullet under `### 路由检查`:

```md
- 如果任务发生在 `/home/zazaki/.config/opencode` 本身，默认应读取这里的 `CURRENT_TASK.md`。
```

- [ ] **Step 3: Update `AGENTS.md` state-file section so it no longer reads like these are only abstract conventions**

Add this single bullet under `## 6. 状态文件与读写` existing bullets:

```md
- 当前 `~/.config/opencode/` 已直接维护 `CURRENT_TASK.md`、`DECISIONS.md`、`AI_GUIDE.md` 与 `handoff/`，后续治理工作默认使用这些真实文件。
```

- [ ] **Step 4: Verify the new state-file references are present in all three governance files**

Run: `rg -n "当前配置目录状态|CURRENT_TASK.md|DECISIONS.md|AI_GUIDE.md|handoff/" "/home/zazaki/.config/opencode/rules/ai/recording-rules.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/AGENTS.md"`
Expected: all newly added references are found.

### Task 4: Validate Phase 2 Outputs

**Files:**
- Modify: `docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md` only if a clear mismatch remains after implementation

- [ ] **Step 1: Check that all newly created state files exist**

Run: `test -f "/home/zazaki/.config/opencode/CURRENT_TASK.md" && test -f "/home/zazaki/.config/opencode/DECISIONS.md" && test -f "/home/zazaki/.config/opencode/AI_GUIDE.md" && test -f "/home/zazaki/.config/opencode/handoff/README.md"`
Expected: command exits with status 0.

- [ ] **Step 2: Check for unresolved markers in the Phase 2 files**

Run: `rg -n "TODO|TBD|FILL" "/home/zazaki/.config/opencode/CURRENT_TASK.md" "/home/zazaki/.config/opencode/DECISIONS.md" "/home/zazaki/.config/opencode/AI_GUIDE.md" "/home/zazaki/.config/opencode/handoff/README.md" "/home/zazaki/.config/opencode/rules/ai/routing-rules.md" "/home/zazaki/.config/opencode/rules/ai/recording-rules.md"`
Expected: no matches.

- [ ] **Step 3: Check that the design spec still matches the current routing and state-file design**

Run: `rg -n "CURRENT_TASK.md|DECISIONS.md|AI_GUIDE.md|handoff/|writing-plans|vibe|subagent-driven-development" "/home/zazaki/.config/opencode/docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md"`
Expected: the design text reflects the current tightened routing and direct state-file landing.

- [ ] **Step 4: Record validation outcome in the final summary**

Include in final report:

```text
Validation run:
- phase 2 state files existence check: pass/fail
- phase 2 unresolved marker scan: pass/fail
- routing tightening check: pass/fail
- governance file reference sync check: pass/fail
```

- [ ] **Step 5: Commit only if this directory becomes a git repository before execution time**

```bash
git add AGENTS.md rules/ai/routing-rules.md rules/ai/recording-rules.md CURRENT_TASK.md DECISIONS.md AI_GUIDE.md handoff/README.md docs/superpowers/specs/2026-05-09-opencode-ai-governance-design.md docs/superpowers/plans/2026-05-09-opencode-ai-governance-phase-2.md
git commit -m "docs: tighten AI routing and add state files"
```

If the directory is still not a git repository, skip commit and state that commit was not possible in the execution summary.
