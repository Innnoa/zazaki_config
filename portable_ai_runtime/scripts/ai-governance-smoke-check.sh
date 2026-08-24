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
    "Quick Routing",
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
    "~/.config/opencode/rules/ai/*.md",
]
for item in required_instructions:
    if item not in instructions:
        errors.append(f"opencode.json missing instruction path: {item}")

smoke_files = [
    root / "references" / "ai" / "session-budget-rules.md",
    root / "references" / "ai" / "governance-smoke-check.md",
    root / "plugins" / "session-governance.ts",
    root / "skills" / "requesting-code-review" / "code-reviewer.md",
    root / "templates" / "ANTI-TEMPLATES.md",
    root / "templates" / "skill" / "SKILL.md",
    root / "templates" / "shells" / "AGENTS.md",
    root / "templates" / "protocol-blocks" / "session-discipline.md",
    root / "templates" / "protocol-blocks" / "aar-check.md",
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

# --- cross-reference scan ----------------------------------------------------
# Recursively extract file references from governance .md files
# and verify that every referenced path exists.
_EXCLUDE_DIRS = {".git", ".worktrees", "node_modules", "ocr-venv", "outputs", "__pycache__"}
def _governance_md_files():
    files = []
    for pattern in ("rules/ai/*.md", "workflows/ai/*.md"):
        for p in root.rglob(pattern):
            if any(part in _EXCLUDE_DIRS for part in p.parts):
                continue
            files.append(p)
    return sorted(set(files))

md_files = _governance_md_files() + [root / "AGENTS.md"]
ref_pattern = re.compile(r"`([^\s`]+\.(?:md|sh|py|ts|json))`")

broken_refs = []
for md_file in sorted(set(md_files)):
    if not md_file.exists():
        continue
    text = md_file.read_text(encoding="utf-8")
    for match in ref_pattern.findall(text):
        ref = match
        if ref.endswith(".md"):
            if ref.startswith("http://") or ref.startswith("https://") or "://" in ref:
                continue
        if "/*" in ref or "<" in ref or ">" in ref:
            continue  # skip glob patterns and template placeholders — cannot resolve to a single file
        if ref.startswith("~/"):
            resolved = Path(ref).expanduser()
        elif not ref.startswith("/") and not ref.startswith("./"):
            # try relative to referencing file first, then relative to root
            candidate = md_file.parent / ref
            if candidate.exists():
                resolved = candidate
            else:
                resolved = root / ref
        elif ref.startswith("./"):
            resolved = md_file.parent / ref[2:]
        else:
            resolved = Path(ref)
        if not resolved.exists():
            broken_refs.append(f"{md_file.relative_to(root)} -> {ref}")

if broken_refs:
    print("FAIL: broken cross-references")
    for br in sorted(set(broken_refs)):
        print(f"  {br}")
    sys.exit(1)

# --- circular-reference check -------------------------------------------------
# Build a reference graph from governance .md files and detect cycles.
from collections import defaultdict

graph = defaultdict(set)  # file -> set of files it references

def resolve_ref(from_file: Path, raw: str) -> str | None:
    if raw.startswith("http://") or raw.startswith("https://") or "://" in raw:
        return None
    if "/*" in raw:
        return None
    if raw.startswith("~/"):
        r = Path(raw).expanduser()
    elif not raw.startswith("/") and not raw.startswith("./"):
        candidate = from_file.parent / raw
        if candidate.exists():
            r = candidate
        else:
            r = root / raw
    elif raw.startswith("./"):
        r = from_file.parent / raw[2:]
    else:
        r = Path(raw)
    if r.exists() and r.suffix == ".md":
        return str(r.resolve())
    return None

for md_file in sorted({p.resolve() for p in _governance_md_files() if p.exists()}):
    text = md_file.read_text(encoding="utf-8")
    for match in ref_pattern.findall(text):
        target = resolve_ref(md_file, match)
        if target:
            graph[str(md_file)].add(target)

def has_cycle(graph: dict) -> list[str] | None:
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {node: WHITE for node in graph}
    parent: dict[str, str | None] = {node: None for node in graph}

    def dfs(node: str) -> list[str] | None:
        color[node] = GRAY
        for neighbor in graph.get(node, set()):
            if color.get(neighbor, WHITE) == GRAY:
                # build cycle path
                cycle = [neighbor, node]
                cur = parent.get(node)
                while cur and cur != neighbor:
                    cycle.append(cur)
                    cur = parent.get(cur)
                return cycle
            if color.get(neighbor, WHITE) == WHITE:
                parent[neighbor] = node
                result = dfs(neighbor)
                if result:
                    return result
        color[node] = BLACK
        return None

    for node in graph:
        if color.get(node, WHITE) == WHITE:
            cycle = dfs(node)
            if cycle:
                return cycle
    return None

cycle = has_cycle(graph)
if cycle:
    rel_cycle = []
    for p in cycle:
        try:
            rel_cycle.append(str(Path(p).relative_to(root)))
        except ValueError:
            rel_cycle.append(p)
    print(f"WARN: circular reference detected (common in governance docs, verify it is intentional)")
    print(f"  cycle: {' -> '.join(reversed(rel_cycle))}")

print("PASS: governance smoke check")
PY
