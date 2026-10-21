#!/usr/bin/env bash
# structure-check.sh — 治理仓结构检查
# 覆盖：符号链接循环 / superpowers 影子复活 / AAR_INBOX 双份 / 本地 skill 唯一性
# 由 regression-test.sh 调用，也可独立运行。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$ROOT_DIR" <<'PY'
import os
import sys

root = sys.argv[1]
errors = []

# ── 1. symlink cycle check ─────────────────────────────────────────────
for dirpath, dirnames, filenames in os.walk(root):
    if any(part in ('.git', '.worktrees', 'node_modules', 'ocr-venv', '.serena',
                    'outputs', '__pycache__', '.venv', 'superpowers.disabled')
           for part in dirpath.split(os.sep)):
        continue
    for d in dirnames:
        full = os.path.join(dirpath, d)
        if os.path.islink(full):
            real = os.path.realpath(full)
            real_parent = os.path.realpath(dirpath)
            # Only a cycle if the link resolves INTO its own parent dir tree
            if real == real_parent or real.startswith(real_parent + os.sep):
                errors.append(f"symlink cycle: {full} -> {os.readlink(full)}")
            elif not os.path.exists(full):
                errors.append(f"broken symlink: {full} -> {os.readlink(full)}")

# ── 2. superpowers shadow resurrection ─────────────────────────────────
sp = os.path.expanduser("~/.agents/skills/superpowers")
if os.path.isdir(sp) and not sp.endswith(".disabled"):
    errors.append("~/.agents/skills/superpowers exists (shadow source for 14 local skills; keep disabled)")

# ── 3. AAR inbox duplication ───────────────────────────────────────────
stale_aar = os.path.join(root, "docs", "ai", "AAR_his", "AAR_INBOX.md")
if os.path.exists(stale_aar):
    errors.append("repo-local docs/ai/AAR_his/AAR_INBOX.md resurrected (authoritative: ~/docs/ai/AAR_his/AAR_INBOX.md)")

# ── 4. local skill uniqueness (superpowers-shadow names) ───────────────
shadow_names = [
    "brainstorming", "dispatching-parallel-agents", "executing-plans",
    "writing-plans", "requesting-code-review", "writing-skills",
    "receiving-code-review", "subagent-driven-development",
    "systematic-debugging", "test-driven-development", "using-git-worktrees",
    "using-superpowers", "verification-before-completion",
    "finishing-a-development-branch",
]
for name in shadow_names:
    if not os.path.exists(os.path.join(root, "skills", name, "SKILL.md")):
        errors.append(f"missing local skill: skills/{name}/SKILL.md")

if errors:
    print("FAIL")
    for e in errors:
        print(f"- {e}")
    sys.exit(1)

print("PASS: structure check")
PY
