# OpenCode Governance To my_config Migration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把当前 `~/.config/opencode` 中已经成熟的 AI 治理系统完整迁入 `~/Projects/my_config/codex_config/portable_dotcodex/`，同时整理成可复用、可提交、可移植的配置包结构。

**Architecture:** 这次迁移不采用“整目录复制”，而采用“结构对齐迁移”。正式治理文件原样迁入 portable pack，当前运行态文件改造成模板，阶段建设历史转为文档归档，现有 `portable_dotcodex` 中仍有价值的模板、MCP profile 和 install 说明保留并更新。这样既能完整保留治理能力，又不会把当前机器的运行现场直接污染到可复用仓库。

**Tech Stack:** Git 仓库 `~/Projects/my_config`、当前 `~/.config/opencode` 治理文件、现有 `portable_dotcodex` 目录结构

---

### Task 1: Replace The Portable Pack Core Governance Files

**Files:**
- Modify: `codex_config/portable_dotcodex/AGENTS.md`
- Create or replace: `codex_config/portable_dotcodex/rules/ai/*.md`
- Create or replace: `codex_config/portable_dotcodex/workflows/ai/*.md`
- Create or replace: `codex_config/portable_dotcodex/references/ai/*.md`

- [ ] **Step 1: Verify target parent directories inside portable pack**

Run: `ls "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex"`
Expected: top-level portable pack exists and is the intended migration target.

- [ ] **Step 2: Replace `portable_dotcodex/AGENTS.md` with the current thin-shell OpenCode version**

Source: `/home/zazaki/.config/opencode/AGENTS.md`
Target: `/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/AGENTS.md`

Expected result:
- top-level file stays thin-shell
- references the full governance entry points
- no old Codex-only long-form rules remain

- [ ] **Step 3: Create `rules/ai/` in portable pack and copy the current governance rule files**

Copy these source files into:
`/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/rules/ai/`

- `governance-principles.md`
- `routing-rules.md`
- `task-closure.md`
- `recording-rules.md`
- `verification-rules.md`
- `agent-mode-selection.md`
- `commit-and-delivery-rules.md`

- [ ] **Step 4: Create `workflows/ai/` in portable pack and copy the current workflow files**

Copy these source files into:
`/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/workflows/ai/`

- `fix-bug.md`
- `implement-feature.md`
- `plan.md`
- `review.md`
- `update-rules.md`
- `trigger-check.md`
- `subagent-routing.md`

- [ ] **Step 5: Create `references/ai/` in portable pack and copy the current reference files**

Copy these source files into:
`/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/references/ai/`

- `gotchas.md`
- `tool-differences.md`
- `anti-patterns.md`
- `trigger-phrases.md`

- [ ] **Step 6: Verify the portable pack now contains the new governance tree**

Run: `ls "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/rules/ai" && ls "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/workflows/ai" && ls "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/references/ai"`
Expected: all copied governance files are listed.

### Task 2: Convert Runtime State Into Portable Templates

**Files:**
- Modify: `codex_config/portable_dotcodex/state-templates/CURRENT_TASK.template.md`
- Modify: `codex_config/portable_dotcodex/state-templates/DECISIONS.template.md`
- Modify: `codex_config/portable_dotcodex/state-templates/AI_GUIDE.template.md`
- Modify or replace: `codex_config/portable_dotcodex/handoff/TEMPLATE.md`

- [ ] **Step 1: Read the current runtime state files and the existing portable templates**

Read sources from:
- `/home/zazaki/.config/opencode/CURRENT_TASK.md`
- `/home/zazaki/.config/opencode/DECISIONS.md`
- `/home/zazaki/.config/opencode/AI_GUIDE.md`
- `/home/zazaki/.config/opencode/handoff/README.md`

Read existing templates from:
- `/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/state-templates/`
- `/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/handoff/TEMPLATE.md`

Expected: understand how much existing template content should be preserved vs replaced.

- [ ] **Step 2: Rewrite the three state templates so they reflect the new governance system, not the current machine state**

Requirements:
- Keep template form, not live instance content
- Preserve reusable structure
- Remove one-off current status lines like “Phase X complete” unless converted into neutral template guidance

Expected result:
- `CURRENT_TASK.template.md` becomes a reusable task-state skeleton
- `DECISIONS.template.md` becomes a reusable decision-log skeleton
- `AI_GUIDE.template.md` becomes a stable anchor template, not a copied live file

- [ ] **Step 3: Update `handoff/TEMPLATE.md` to match the current handoff expectations**

Requirements:
- reflect concise handoff content
- avoid raw session log style
- align with current `handoff/README.md` expectations

- [ ] **Step 4: Verify templates no longer contain live machine-specific task state**

Run: `rg -n "Phase 1|Phase 2|Phase 3|Phase 4|Phase 5|2026-05-09 - Governance" "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/state-templates" "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/handoff/TEMPLATE.md"`
Expected: no live governance phase anchors remain in templates.

### Task 3: Archive The Current Governance Build History As Documentation

**Files:**
- Create: `codex_config/portable_dotcodex/docs/governance/README.md`
- Create: `codex_config/portable_dotcodex/docs/governance/history/`
- Copy selected docs from current `~/.config/opencode/docs/superpowers/`

- [ ] **Step 1: Create governance archive directories inside portable pack**

Create:
- `docs/governance/README.md`
- `docs/governance/history/`

- [ ] **Step 2: Copy the current governance design and migration-relevant plans into the history directory**

Copy these sources into:
`/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/docs/governance/history/`

- `2026-05-09-opencode-ai-governance-design.md`
- `2026-05-09-opencode-ai-governance-phase-1.md`
- `2026-05-09-opencode-ai-governance-phase-2.md`
- `2026-05-09-opencode-ai-governance-phase-3.md`
- `2026-05-09-opencode-ai-governance-phase-4.md`
- `2026-05-09-opencode-ai-governance-phase-5.md`
- `2026-05-09-opencode-subagent-routing-protocol.md`

- [ ] **Step 3: Write `docs/governance/README.md` to explain the difference between active portable rules and archived build history**

Content must explain:
- active runtime governance lives under `AGENTS.md`, `rules/ai/`, `workflows/ai/`, `references/ai/`
- archived history lives under `docs/governance/history/`
- history is for reference, not the live source of truth

- [ ] **Step 4: Verify the archive exists and the active/runtime tree stays separate**

Run: `ls "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/docs/governance/history" && rg -n "active runtime governance|history is for reference" "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/docs/governance/README.md"`
Expected: copied history files exist and README explains the separation.

### Task 4: Update Portable Pack Documentation And Validate Migration

**Files:**
- Modify: `codex_config/README.md`
- Modify: `README.md`

- [ ] **Step 1: Update `codex_config/README.md` so the included/excluded sections match the migrated pack**

It should now mention:
- `rules/ai/`
- `workflows/ai/`
- `references/ai/`
- archived governance docs
- state templates remain templates, not live state

- [ ] **Step 2: Update repo-root `README.md` with a brief explanation of what `my_config` now contains**

At minimum mention:
- this repo stores portable AI/codex governance configuration
- `codex_config/portable_dotcodex/` is the reusable runtime pack

- [ ] **Step 3: Run final migration validation checks**

Run all of the following:

- `rg -n "rules/ai|workflows/ai|references/ai" "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/AGENTS.md"`
- `test -f "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/rules/ai/governance-principles.md" && test -f "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/workflows/ai/subagent-routing.md" && test -f "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/references/ai/trigger-phrases.md"`
- `rg -n "Trigger Check Result Format|Phase 1|Phase 2|Phase 3|Phase 4|Phase 5" "/home/zazaki/Projects/my_config/codex_config/portable_dotcodex/state-templates/AI_GUIDE.template.md"`

Expected:
- AGENTS points to the new governance tree
- key governance files exist
- templates contain reusable format, not copied live phase history

- [ ] **Step 4: Commit if validation passes**

```bash
git add codex_config/portable_dotcodex codex_config/README.md README.md
git commit -m "feat: migrate opencode governance into portable codex config"
```

If commit fails, report the failure reason exactly and do not amend.
