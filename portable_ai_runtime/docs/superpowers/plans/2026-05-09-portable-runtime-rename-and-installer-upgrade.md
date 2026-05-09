# Portable Runtime Rename And Installer Upgrade Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把当前 `codex_config/` 重命名为更准确的可移植 AI runtime 名称，并把 `install.sh` 从粗复制脚本升级为支持 `install` / `update` 的轻量安装器。

**Architecture:** 这次改造先只重命名外层目录，不改内层 `portable_dotcodex/`。这样可以先修正“目录名字已不再准确”的问题，同时把安装器升级为两模式：首次安装走 `install`，已有环境升级走 `update`。脚本仍然围绕 `portable_dotcodex/` 作为 runtime pack 本体工作，但会显式区分 live state、template、治理文件和覆盖风险，避免继续使用“整包无差别复制”的旧行为。

**Tech Stack:** Git 仓库 `~/Projects/my_config`、shell 脚本、Markdown 文档、现有 `portable_dotcodex/` 结构

---

### Task 1: Rename The Outer Directory And Update Basic References

**Files:**
- Rename: `codex_config/` -> `portable_ai_runtime/`
- Modify: `README.md`
- Modify: `portable_ai_runtime/README.md`

- [ ] **Step 1: Verify the current outer directory exists and the target name does not already exist**

Run: `ls "/home/zazaki/Projects/my_config"`
Expected: `codex_config/` exists and `portable_ai_runtime/` does not yet exist.

- [ ] **Step 2: Rename the outer directory**

Run: `mv "/home/zazaki/Projects/my_config/codex_config" "/home/zazaki/Projects/my_config/portable_ai_runtime"`
Expected: rename completes successfully.

- [ ] **Step 3: Update repo-root `README.md` to use the new outer directory name**

Required changes:
- replace `codex_config/portable_dotcodex/` references with `portable_ai_runtime/portable_dotcodex/`
- replace `codex_config/README.md` reference with `portable_ai_runtime/README.md`

- [ ] **Step 4: Update `portable_ai_runtime/README.md` title and usage text to match the new outer directory identity**

Requirements:
- remove the assumption that this is just “Codex Config Portable Pack”
- describe it as a portable AI runtime pack that currently targets `~/.codex/`
- keep inner `portable_dotcodex/` references unchanged for now

- [ ] **Step 5: Verify no top-level docs still point to the old outer directory name**

Run: `rg -n "codex_config/" "/home/zazaki/Projects/my_config/README.md" "/home/zazaki/Projects/my_config/portable_ai_runtime/README.md"`
Expected: no stale references remain.

### Task 2: Upgrade install.sh Into A Two-Mode Installer

**Files:**
- Modify: `portable_ai_runtime/install.sh`

- [ ] **Step 1: Preserve the current script behavior as a baseline and then rewrite it for mode-based execution**

Target interface:

```bash
./install.sh install [target_dir] [--init-state]
./install.sh update [target_dir]
```

Requirements:
- default target stays `~/.codex`
- `install` copies the runtime pack and creates `config.toml` from template only if missing
- `update` updates governance/runtime files but does not overwrite live state files or `config.toml`
- `--init-state` is only valid with `install`

- [ ] **Step 2: Define explicit file-handling behavior inside the script**

Script must clearly distinguish:

- runtime pack files to copy/update
- `config.toml` handling
- live state files to never overwrite by default:
  - `AI_GUIDE.md`
  - `CURRENT_TASK.md`
  - `DECISIONS.md`
  - `handoff/`

- [ ] **Step 3: Add human-readable warnings before destructive-looking actions**

Requirements:
- before `install`, print what target directory will receive the pack
- before `update`, print that governance/runtime files may be replaced
- print that live state files are preserved during `update`

- [ ] **Step 4: Add optional state initialization for install mode**

When `--init-state` is passed with `install`:
- initialize `AI_GUIDE.md`, `CURRENT_TASK.md`, `DECISIONS.md` from `state-templates/`
- initialize a handoff template or handoff directory starter if appropriate
- do not overwrite existing live state files

- [ ] **Step 5: Keep the script simple; do not add unrelated environment detection or platform-specific complexity**

The script should remain understandable from one screen of reading and stay focused on runtime pack install/update.

- [ ] **Step 6: Verify the new installer interface text exists**

Run: `rg -n "install \[target_dir\] \[--init-state\]|update \[target_dir\]|do not overwrite live state|config.toml" "/home/zazaki/Projects/my_config/portable_ai_runtime/install.sh"`
Expected: the new installer behavior is visible in the script.

### Task 3: Update Runtime Pack Documentation For The New Installer Behavior

**Files:**
- Modify: `portable_ai_runtime/README.md`

- [ ] **Step 1: Update the usage section to reflect install/update modes**

The README should now explain:
- `install` is for new environments
- `update` is for upgrading an existing `~/.codex/`
- `--init-state` initializes state files from templates

- [ ] **Step 2: Add a short note about preserved files during update**

Must mention that update does not overwrite by default:
- `config.toml`
- live state files

- [ ] **Step 3: Verify the README explains the new script modes**

Run: `rg -n "install|update|--init-state|does not overwrite|live state" "/home/zazaki/Projects/my_config/portable_ai_runtime/README.md"`
Expected: the README clearly documents the new installer behavior.

### Task 4: Validate And Commit The Rename/Installer Upgrade

**Files:**
- No new target files beyond those above; only fix mismatches if validation finds a clear issue

- [ ] **Step 1: Check for unresolved markers in touched files**

Run: `rg -n "TODO|TBD|FILL" "/home/zazaki/Projects/my_config/README.md" "/home/zazaki/Projects/my_config/portable_ai_runtime/README.md" "/home/zazaki/Projects/my_config/portable_ai_runtime/install.sh"`
Expected: no matches.

- [ ] **Step 2: Check for stale outer-directory references in the repo**

Run: `rg -n "codex_config/" "/home/zazaki/Projects/my_config"`
Expected: no remaining references that should have been renamed for the outer directory move.

- [ ] **Step 3: Run git status and review changed files before commit**

Run: `git status --short`
Expected: only the intended rename/install-doc changes and any pre-existing unrelated changes are visible and can be distinguished.

- [ ] **Step 4: Commit only the rename/install-upgrade changes**

```bash
git add README.md portable_ai_runtime && git commit -m "feat: rename portable runtime pack and upgrade installer"
```

If unrelated tracked changes remain outside this scope, do not include them. If commit fails, report the exact reason and do not amend.
