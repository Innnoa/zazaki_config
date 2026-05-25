#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$ROOT_DIR" <<'PY'
from pathlib import Path
import json
import re
import sys

root = Path(sys.argv[1])
errors = []

agents = (root / "AGENTS.md").read_text(encoding="utf-8")
required_blocks = [
    "Always Read",
    "Session Discipline",
    "Common Tasks",
    "Auto-Triggers",
    "Red Flags - STOP",
    "Known Gotchas",
]
for block in required_blocks:
    if not re.search(rf"^#+\s+{re.escape(block)}\s*$", agents, flags=re.MULTILINE):
        errors.append(f"AGENTS.md missing block: {block}")

config = json.loads((root / "opencode.json").read_text(encoding="utf-8"))
instructions = config.get("instructions", [])
required_instructions = [
    "~/.config/opencode/rules/*.md",
    "~/.config/opencode/rules/ai/*.md",
]
for item in required_instructions:
    if item not in instructions:
        errors.append(f"opencode.json missing instruction path: {item}")

smoke_files = [
    root / "rules" / "ai" / "session-discipline.md",
    root / "references" / "ai" / "session-budget-rules.md",
    root / "references" / "ai" / "governance-smoke-check.md",
    root / "plugins" / "session-governance.ts",
    root / "skills" / "requesting-code-review" / "code-reviewer.md",
]
for path in smoke_files:
    if not path.exists():
        errors.append(f"missing file: {path.relative_to(root)}")

zshrc_path = root.parent.parent / ".zshrc"

verification = (root / "rules" / "ai" / "verification-rules.md").read_text(encoding="utf-8")
if "governance-smoke-check.md" not in verification:
    errors.append("verification-rules.md does not reference governance-smoke-check.md")

current_task = (root / "CURRENT_TASK.md").read_text(encoding="utf-8")
current_task_markers = ["## 目标", "## 范围", "## 当前状态", "## 下一步"]
for marker in current_task_markers:
    if marker not in current_task:
        errors.append(f"CURRENT_TASK.md missing section: {marker}")

if "Brave + fetch" in current_task or "exa_search" in current_task:
    errors.append("CURRENT_TASK.md still contains stale prior-task content")

skill_files = [
    root / "skills" / "context-handoff" / "SKILL.md",
    root / "skills" / "vibe" / "SKILL.md",
    root / "skills" / "using-superpowers" / "SKILL.md",
    root / "skills" / "requesting-code-review" / "SKILL.md",
]
for path in skill_files:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"^description:\s*\"?([^\n\"]+)\"?\s*$", text, flags=re.MULTILINE)
    if not match:
        errors.append(f"missing skill description: {path.relative_to(root)}")
        continue
    description = match.group(1).strip()
    if not description.startswith("Use when"):
        errors.append(f"skill description should start with 'Use when': {path.relative_to(root)}")

high_frequency_skill_limits = {
    root / "skills" / "using-superpowers" / "SKILL.md": 300,
    root / "skills" / "context-handoff" / "SKILL.md": 300,
    root / "skills" / "vibe" / "SKILL.md": 550,
}
for path, limit in high_frequency_skill_limits.items():
    text = path.read_text(encoding="utf-8")
    words = len(re.findall(r"\S+", text))
    if words > limit:
        errors.append(
            f"high-frequency skill exceeds word budget ({words}>{limit}): {path.relative_to(root)}"
        )

config_text = (root / "opencode.json").read_text(encoding="utf-8")
required_env_markers = [
    "{env:MIMO_API_KEY}",
    "{env:FASTAICODE_API_KEY}",
    "{env:BRAVE_API_KEY}",
    "{env:DEEPSEEK_API_KEY}",
]
if any(marker in config_text for marker in required_env_markers):
    provider_env_file = root / "provider-secrets.env"
    if not provider_env_file.exists():
        errors.append("opencode.json requires provider-secrets.env-backed env vars but provider-secrets.env is missing")
    if not zshrc_path.exists():
        errors.append("opencode.json requires provider-secrets.env-backed env vars but ~/.zshrc is missing")
    else:
        zshrc_text = zshrc_path.read_text(encoding="utf-8")
        if 'source "$HOME/.config/opencode/provider-secrets.env"' not in zshrc_text:
            errors.append("opencode.json requires provider-secrets.env-backed env vars but ~/.zshrc does not source provider-secrets.env")

budget = (root / "references" / "ai" / "session-budget-rules.md").read_text(encoding="utf-8")
required_budget_markers = [
    "100000 tokens",
    "150000 tokens",
    "上下文已超过 150000 tokens，请开启新会话。",
]
for marker in required_budget_markers:
    if marker not in budget and marker not in agents:
        errors.append(f"missing budget marker: {marker}")

disallowed_patterns = [
    "已建立强制运行时门禁",
    "运行时已经自动拦截",
    "已自动强制门禁",
]
allowed_negation_markers = [
    "不得把",
    "不要把",
    "没有",
    "未",
    "除非",
]
for line in (agents + "\n" + verification + "\n" + budget).splitlines():
    stripped = line.strip()
    if not stripped:
        continue
    for phrase in disallowed_patterns:
        if phrase not in stripped:
            continue
        if any(marker in stripped for marker in allowed_negation_markers):
            continue
        errors.append(f"disallowed runtime-gate claim found: {phrase}")

if errors:
    print("FAIL")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("PASS: governance smoke check")
PY
