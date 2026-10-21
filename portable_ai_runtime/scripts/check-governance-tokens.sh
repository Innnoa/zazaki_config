#!/usr/bin/env bash
set -euo pipefail
# check-governance-tokens.sh — audit total governance token footprint
# Uses Python tiktoken for accurate per-file counts with cl100k_base encoding.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

python3 - "$ROOT_DIR" <<'PY'
import sys, os, json
from pathlib import Path

root = Path(sys.argv[1])

# Use tiktoken if available, otherwise fall back to char/2 estimate
try:
    import tiktoken
    enc = tiktoken.get_encoding("cl100k_base")
    def count_tokens(path: Path) -> int:
        return len(enc.encode(path.read_text(encoding="utf-8", errors="replace")))
    TOKENIZER = "tiktoken (cl100k_base)"
except ImportError:
    def count_tokens(path: Path) -> int:
        text = path.read_text(encoding="utf-8", errors="replace")
        return max(1, len(text) // 2)
    TOKENIZER = "char/2 estimate (tiktoken not installed)"

errors = 0
total_tokens = 0

print("=== Governance Token Audit ===")
print(f"Tokenizer: {TOKENIZER}")
print()

# ── Always-injected thin shell: instructions ─────────────────────
# AGENTS.md is auto-loaded by opencode (measured under entry + plugin),
# so the instructions surface is the routing authority only.
print("--- always injected (instructions) ---")
instr_files = [
    root / "rules/ai/routing-rules.md",
]
instr_total = 0
for f in instr_files:
    if not f.exists():
        print(f"  {f.relative_to(root):<45} MISSING")
        errors += 1
        continue
    tokens = count_tokens(f)
    instr_total += tokens
    print(f"  {str(f.relative_to(root)):<45} {tokens} tokens")
print(f"  {'subtotal (always injected)':<45} {instr_total} tokens")
print()

# ── On-demand rules ──────────────────────────────────────────────
print("--- on-demand rules/ai/ ---")
on_demand_total = 0
always_injected_names = {"rules/ai/routing-rules.md"}
for f in sorted(root.glob("rules/ai/*.md")):
    rel = str(f.relative_to(root))
    if rel in always_injected_names:
        continue
    if not f.exists():
        continue
    tokens = count_tokens(f)
    on_demand_total += tokens
    print(f"  {rel:<45} {tokens} tokens")
print(f"  {'subtotal (on-demand rules)':<45} {on_demand_total} tokens")
print()

# ── Workflows ────────────────────────────────────────────────────
print("--- workflows/ai/ ---")
wf_total = 0
for f in sorted(root.glob("workflows/ai/*.md")):
    tokens = count_tokens(f)
    wf_total += tokens
    print(f"  {str(f.relative_to(root)):<45} {tokens} tokens")
print(f"  {'subtotal (workflows)':<45} {wf_total} tokens")
print()

# ── References ───────────────────────────────────────────────────
print("--- references/ai/ ---")
ref_total = 0
for f in sorted(root.glob("references/ai/*.md")):
    tokens = count_tokens(f)
    ref_total += tokens
    print(f"  {str(f.relative_to(root)):<45} {tokens} tokens")
print(f"  {'subtotal (references)':<45} {ref_total} tokens")
print()

# ── Entry + Plugin ───────────────────────────────────────────────
print("--- entry + plugin ---")
agents_f = root / "AGENTS.md"
plugin_f = root / "plugins" / "session-governance" / "index.ts"
agents_tokens = count_tokens(agents_f) if agents_f.exists() else 0
plugin_tokens = count_tokens(plugin_f) if plugin_f.exists() else 0
print(f"  {'AGENTS.md':<45} {agents_tokens} tokens")
print(f"  {'plugins/session-governance/index.ts':<45} {plugin_tokens} tokens")
print(f"  {'subtotal (entry+plugin)':<45} {agents_tokens + plugin_tokens} tokens")
print()

# ── Agents ───────────────────────────────────────────────────────
print("--- agents/ ---")
agent_total = 0
for f in sorted(root.glob("agents/*.md")):
    tokens = count_tokens(f)
    agent_total += tokens
    print(f"  {str(f.relative_to(root)):<45} {tokens} tokens")
if agent_total == 0:
    print("  (none)")
print(f"  {'subtotal (agents)':<45} {agent_total} tokens")
print()

# ── Totals ───────────────────────────────────────────────────────
grand_total = instr_total + on_demand_total + wf_total + ref_total + agents_tokens + plugin_tokens + agent_total
shell_estimate = 500
runtime_context = instr_total + shell_estimate

print("=========================================")
print(f"{'always injected (instructions)':<45} {instr_total} tokens")
print(f"{'governance shell (system.transform)':<45} ~{shell_estimate} tokens")
print(f"{'estimated runtime context':<45} ~{runtime_context} tokens")
print(f"{'on-demand (rules+workflows+refs)':<45} {on_demand_total + wf_total + ref_total} tokens")
print(f"{'entry + plugin + agents':<45} {agents_tokens + plugin_tokens + agent_total} tokens")
print(f"{'grand total (all files)':<45} {grand_total} tokens")
print("=========================================")
print()

# ── Budget checks ────────────────────────────────────────────────
MAX_PER_FILE = 2500
MAX_ALWAYS_INJECTED = 3000

print("--- budget checks ---")
for f in sorted(root.glob("rules/ai/*.md")):
    tokens = count_tokens(f)
    if tokens > MAX_PER_FILE:
        print(f"  \033[0;31mFAIL\033[0m: {f.relative_to(root)} ({tokens} tokens > {MAX_PER_FILE})")
        errors += 1

if instr_total > MAX_ALWAYS_INJECTED:
    print(f"  \033[0;31mFAIL\033[0m: always-injected total ({instr_total} tokens > {MAX_ALWAYS_INJECTED})")
    errors += 1

if errors == 0:
    print(f"  \033[0;32mPASS\033[0m: all files within token budget")
    print()
    sys.exit(0)
else:
    print()
    print(f"\033[0;31mFAIL\033[0m: {errors} budget violations")
    sys.exit(1)
PY
