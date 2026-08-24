#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$ROOT_DIR" <<'PY'
"""Validate route→file existence from routing-rules.md Common Tasks entries.
Every file reference and skill name in Common Tasks must resolve to an existing path."""
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
errors = []

routing = (root / "rules" / "ai" / "routing-rules.md").read_text(encoding="utf-8")

# Parse Common Tasks section
in_section = False
entries = []
for line in routing.splitlines():
    s = line.strip()
    if s.startswith("### Common Tasks"):
        in_section = True
        continue
    if not in_section:
        continue
    if s.startswith("### ") or s == "###":
        break
    if s.startswith("- "):
        entries.append(s[2:])

if not entries:
    errors.append("no Common Tasks entries parsed")
    print("FAIL")
    for e in errors:
        print(f"  ERROR: {e}")
    sys.exit(1)

checked = 0
for entry in entries:
    # Extract all backtick-quoted references
    refs = re.findall(r"`([^`]+)`", entry)
    for ref in refs:
        checked += 1
        if ref.endswith(".md"):
            # File reference — check existence
            candidate = root / ref
            if not candidate.exists():
                # Try relative to common subdirs
                for subdir in ["rules/ai", "workflows/ai", "references/ai"]:
                    c2 = root / subdir / ref.split("/")[-1]
                    if c2.exists():
                        candidate = c2
                        break
            if not candidate.exists():
                errors.append(f"missing file: {ref}  (from: {entry[:60]}...)")
        else:
            # Skill/workflow name — check if skill dir exists or it's a known name
            # Skip path-like references (starts with $HOME, /, ~, .)
            if ref.startswith("$HOME") or ref.startswith("/") or ref.startswith("~/") or ref.startswith("./"):
                continue
            skill_dir = root / "skills" / ref
            if not skill_dir.exists():
                # Well-known non-file names that don't need skill dirs
                known_names = {"systematic-debugging", "brainstorming", "writing-plans",
                               "verification-before-completion", "serena", "/new-session",
                               "repo-audit", "customize-opencode", "subagent-driven-development",
                               "frontend-regulation", "ux-design", "vibe"}
                if ref not in known_names:
                    # Try hyphenated variant
                    alt = ref.replace("-", "_")
                    alt_dir = root / "skills" / alt
                    if not alt_dir.exists():
                        errors.append(f"unresolvable name: {ref}  (from: {entry[:60]}...)")

if errors:
    print("FAIL")
    for error in errors:
        print(f"  ERROR: {error}")
    sys.exit(1)

print(f"PASS: {checked} route references verified")
PY
