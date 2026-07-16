#!/usr/bin/env bash
set -euo pipefail
# check-governance-tokens.sh — audit total governance token footprint
# Uses zazaki_tokenizer for accurate per-file counts.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

TOKENIZER="zazaki_tokenizer"

if ! command -v "$TOKENIZER" &>/dev/null; then
  echo "ERROR: $TOKENIZER not found in PATH"
  exit 1
fi

count_file() {
  local raw
  raw=$("$TOKENIZER" count -f "$1" 2>/dev/null) || { echo "0"; return; }
  echo "${raw%% *}"  # extract number before " tokens"
}

errors=0
total_tokens=0
declare -a file_results

echo "=== Governance Token Audit ==="
echo ""

# ── Always-injected: instructions (3 files) ──────────────────────
echo "--- always injected (instructions) ---"
instr_total=0
for f in \
  "$ROOT_DIR/rules/ai/routing-rules.md" \
  "$ROOT_DIR/rules/ai/task-closure.md" \
  "$ROOT_DIR/rules/ai/verification-rules.md"; do
  tokens=$(count_file "$f")
  instr_total=$((instr_total + tokens))
  printf "  %-45s %s tokens\n" "$(echo "$f" | sed "s|$ROOT_DIR/||")" "$tokens"
done
printf "  %-45s %s tokens\n" "subtotal (always injected)" "$instr_total"
echo ""

# ── On-demand rules ──────────────────────────────────────────────
echo "--- on-demand rules/ai/ ---"
on_demand_total=0
for f in "$ROOT_DIR"/rules/ai/*.md; do
  fname=$(echo "$f" | sed "s|$ROOT_DIR/||")
  case "$fname" in
    rules/ai/routing-rules.md|rules/ai/task-closure.md|rules/ai/verification-rules.md)
      continue ;;  # already counted above
  esac
  tokens=$(count_file "$f")
  on_demand_total=$((on_demand_total + tokens))
  printf "  %-45s %s tokens\n" "$fname" "$tokens"
done
printf "  %-45s %s tokens\n" "subtotal (on-demand rules)" "$on_demand_total"
echo ""

# ── Workflows ────────────────────────────────────────────────────
echo "--- workflows/ai/ ---"
wf_total=0
for f in "$ROOT_DIR"/workflows/ai/*.md; do
  tokens=$(count_file "$f")
  wf_total=$((wf_total + tokens))
  printf "  %-45s %s tokens\n" "$(echo "$f" | sed "s|$ROOT_DIR/||")" "$tokens"
done
printf "  %-45s %s tokens\n" "subtotal (workflows)" "$wf_total"
echo ""

# ── References ───────────────────────────────────────────────────
echo "--- references/ai/ ---"
ref_total=0
for f in "$ROOT_DIR"/references/ai/*.md; do
  tokens=$(count_file "$f")
  ref_total=$((ref_total + tokens))
  printf "  %-45s %s tokens\n" "$(echo "$f" | sed "s|$ROOT_DIR/||")" "$tokens"
done
printf "  %-45s %s tokens\n" "subtotal (references)" "$ref_total"
echo ""

# ── Entry + Plugin ───────────────────────────────────────────────
echo "--- entry + plugin ---"
agents_tokens=$(count_file "$ROOT_DIR/AGENTS.md")
plugin_tokens=$(count_file "$ROOT_DIR/plugins/session-governance.ts")
printf "  %-45s %s tokens\n" "AGENTS.md" "$agents_tokens"
printf "  %-45s %s tokens\n" "plugins/session-governance.ts" "$plugin_tokens"
printf "  %-45s %s tokens\n" "subtotal (entry+plugin)" "$((agents_tokens + plugin_tokens))"
echo ""

# ── Totals ───────────────────────────────────────────────────────
grand_total=$((instr_total + on_demand_total + wf_total + ref_total + agents_tokens + plugin_tokens))
always_injected_total=$((instr_total))
# Governance Shell summary (~20 lines hardcoded, estimated ~500 tokens)
shell_estimate=500
runtime_context=$((always_injected_total + shell_estimate))

echo "========================================="
printf "%-45s %s tokens\n" "always injected (instructions)" "$always_injected_total"
printf "%-45s %s tokens\n" "governance shell (system.transform)" "~$shell_estimate"
printf "%-45s %s tokens\n" "estimated runtime context" "~$runtime_context"
printf "%-45s %s tokens\n" "on-demand (rules+workflows+refs)" "$((on_demand_total + wf_total + ref_total))"
printf "%-45s %s tokens\n" "entry + plugin" "$((agents_tokens + plugin_tokens))"
printf "%-45s %s tokens\n" "grand total (all files)" "$grand_total"
echo "========================================="
echo ""

# ── Budget checks ────────────────────────────────────────────────
MAX_PER_FILE=2000
MAX_ALWAYS_INJECTED=4000

echo "--- budget checks ---"
for f in "$ROOT_DIR"/rules/ai/*.md; do
  tokens=$(count_file "$f")
  if [ "$tokens" -gt "$MAX_PER_FILE" ]; then
    echo -e "  ${RED}FAIL${NC}: $(echo "$f" | sed "s|$ROOT_DIR/||") ($tokens tokens > $MAX_PER_FILE)"
    errors=$((errors + 1))
  fi
done

if [ "$always_injected_total" -gt "$MAX_ALWAYS_INJECTED" ]; then
  echo -e "  ${RED}FAIL${NC}: always-injected total ($always_injected_total tokens > $MAX_ALWAYS_INJECTED)"
  errors=$((errors + 1))
fi

if [ "$errors" -eq 0 ]; then
  echo -e "  ${GREEN}PASS${NC}: all files within token budget"
  echo ""
  exit 0
else
  echo ""
  echo -e "${RED}FAIL${NC}: $errors budget violations"
  exit 1
fi
