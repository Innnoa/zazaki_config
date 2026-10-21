#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
RESULTS=()

run_check() {
  local name="$1"
  local cmd="$2"
  local output
  local runner="bash"
  case "$cmd" in
    *.py) runner="python3" ;;
  esac
  if output=$("$runner" "$ROOT/scripts/$cmd" 2>&1); then
    RESULTS+=("PASS: $name")
    PASS=$((PASS + 1))
  else
    RESULTS+=("FAIL: $name")
    FAIL=$((FAIL + 1))
  fi
  echo "$output" | while IFS= read -r line; do echo "  $line"; done
}

echo "=== Governance Regression Test ==="
echo ""

run_check "smoke check"              "ai-governance-smoke-check.sh"
echo ""
run_check "trigger check"            "ai-trigger-check.sh"
echo ""
run_check "route refs"               "test-trigger.sh"
echo ""
run_check "token budgets"            "check-governance-tokens.sh"
echo ""
run_check "vibe paths"                "check-vibe-config-paths.py"
echo ""
run_check "gitignore check"          "gitignore-check.sh"
echo ""
run_check "structure check"          "structure-check.sh"
echo ""
run_check "doc drift audit"          "doc-drift-audit.sh"
echo ""

echo "=== Results ==="
for r in "${RESULTS[@]}"; do
  echo "$r"
done
echo ""
echo "PASS: $PASS  FAIL: $FAIL"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
