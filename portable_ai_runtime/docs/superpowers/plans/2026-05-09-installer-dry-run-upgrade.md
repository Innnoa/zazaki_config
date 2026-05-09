# Installer Dry-Run Upgrade Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 `portable_ai_runtime/install.sh` 增加 `dry-run / preview` 能力，使安装或更新前可以先查看脚本将执行的动作，而不实际写入目标目录。

**Architecture:** 保持现有 `install` / `update` 双模式结构不变，只增加一个轻量 preview 层。该层不引入复杂依赖、不做真实文件写入、不尝试 diff 目标内容，只输出目标目录、运行模式、会复制或更新的内容、会保留的内容，以及 `--init-state` 的影响范围。这样能在不破坏脚本简洁性的前提下，明显提升使用安全感和可审计性。

**Tech Stack:** shell 脚本、现有 `portable_ai_runtime/install.sh`、`portable_ai_runtime/README.md`

---

### Task 1: Add A Dry-Run Flag To install.sh

**Files:**
- Modify: `portable_ai_runtime/install.sh`

- [ ] **Step 1: Extend argument parsing to recognize a dry-run flag**

Requirements:
- support `--dry-run` for both `install` and `update`
- keep current positional command structure intact
- reject invalid combinations cleanly

Accepted forms should include:

```bash
./install.sh install [target_dir] [--init-state] [--dry-run]
./install.sh update [target_dir] [--dry-run]
```

- [ ] **Step 2: Add a dry-run branch for install mode**

Dry-run output for `install` must clearly state:
- target directory
- that the runtime pack would be copied
- whether `config.toml` would be created or preserved
- whether `--init-state` would initialize missing state files
- that no files are actually written in dry-run mode

- [ ] **Step 3: Add a dry-run branch for update mode**

Dry-run output for `update` must clearly state:
- target directory
- that governance/runtime files would be updated
- that `config.toml` would be preserved if already present
- that live state files would not be overwritten
- that no files are actually written in dry-run mode

- [ ] **Step 4: Keep the script simple and avoid fake precision**

Requirements:
- do not attempt per-file diff simulation
- do not attempt backup logic in this phase
- output only what the script can reliably guarantee

- [ ] **Step 5: Verify the script now contains the dry-run interface markers**

Run: `rg -n "--dry-run|dry-run mode|no files are actually written|live state files" "/home/zazaki/Projects/my_config/portable_ai_runtime/install.sh"`
Expected: all key dry-run phrases are present.

### Task 2: Update README For Dry-Run Usage

**Files:**
- Modify: `portable_ai_runtime/README.md`

- [ ] **Step 1: Update the usage section to mention dry-run for both install and update**

README must explain:
- `install --dry-run` previews first-time installation behavior
- `update --dry-run` previews runtime/governance update behavior

- [ ] **Step 2: Add one short note about what dry-run does not do**

Must explain that dry-run:
- does not write files
- does not perform per-file content diffing
- is a high-level action preview only

- [ ] **Step 3: Verify README includes dry-run examples or wording**

Run: `rg -n "dry-run|--dry-run|preview|does not write files" "/home/zazaki/Projects/my_config/portable_ai_runtime/README.md"`
Expected: dry-run behavior is clearly documented.

### Task 3: Validate The Dry-Run Upgrade

**Files:**
- No additional target files beyond those above; only fix clear mismatches if found

- [ ] **Step 1: Check for unresolved markers in touched files**

Run: `rg -n "TODO|TBD|FILL" "/home/zazaki/Projects/my_config/portable_ai_runtime/install.sh" "/home/zazaki/Projects/my_config/portable_ai_runtime/README.md"`
Expected: no matches.

- [ ] **Step 2: Execute dry-run examples without writing files**

Run both:

```bash
./install.sh install "/tmp/portable-runtime-dry-run-test" --init-state --dry-run
./install.sh update "/tmp/portable-runtime-dry-run-test" --dry-run
```

Expected:
- both commands exit successfully
- both commands print preview information
- target directory content is not created or modified by dry-run itself

- [ ] **Step 3: Record validation outcome in the final summary**

Include in final report:

```text
Validation run:
- unresolved marker scan: pass/fail
- dry-run interface text check: pass/fail
- install dry-run execution: pass/fail
- update dry-run execution: pass/fail
```

- [ ] **Step 4: Commit only if the validation passes**

```bash
git add portable_ai_runtime/install.sh portable_ai_runtime/README.md portable_ai_runtime/docs/superpowers/plans/2026-05-09-installer-dry-run-upgrade.md
git commit -m "feat: add installer dry-run mode"
```

If commit fails, report the exact reason and do not amend.
