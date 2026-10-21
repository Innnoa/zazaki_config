#!/usr/bin/env bash
# doc-drift-audit.sh — negative-content drift audit for the AI-governance repo.
#
# Table-driven regression gate: every must-not pattern must have 0 matches,
# every must-contain pattern must have >= 1 match, in the given file.
# Root dir = the repo root, derived from this script's location (script's
# parent dir is scripts/; the files below are repo-root-relative), matching
# the convention used by the sibling audit scripts.
#
# Maintenance discipline: when an audit/review finds a NEW drift type (a
# restated schema, stale claim, forbidden token), add it to the table below
# as a must-not/must-contain entry so it becomes a permanent regression gate.
# Historical sections that legitimately retain superseded wording must carry
# an OBSOLETE / 已被取代 marker on the same line; the AI_GUIDE special rule
# below shows the accepted pattern for that case.
#
# Usage: bash scripts/doc-drift-audit.sh
# Exit 0 + "PASS: doc drift audit" when the whole table holds.
# Exit 1 + one "FAIL: <file> contains/requires <pattern>" per violation otherwise.

set -u

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# must-not: file|regex  (0 matches required)
MUST_NOT=(
  "references/ai/verification-templates.md|已建立真实运行时门禁"
  "references/ai/verification-templates.md|Role / Goal|Scope / Constraints|Expected Output"
  "workflows/ai/subagent-routing.md|Role / Goal|Scope / Constraints|Expected Output"
  "opencode.json|mimo"
  "plugins/verify-gates/index.ts|playwright|screenshot"
  "scripts/ai-governance-smoke-check.sh|Brave|exa_search"
)

# must-contain: file|regex  (>=1 match required)
MUST_CONTAIN=(
  "rules/ai/auto-trigger-rules.md|Latte"
  "DECISIONS.md|已被取代|superseded"
)

failed=0

for entry in "${MUST_NOT[@]}"; do
  file="${entry%%|*}"
  pattern="${entry#*|}"
  if grep -qE "$pattern" "$ROOT_DIR/$file" 2>/dev/null; then
    echo "FAIL: $file contains $pattern"
    failed=1
  fi
done

for entry in "${MUST_CONTAIN[@]}"; do
  file="${entry%%|*}"
  pattern="${entry#*|}"
  if ! grep -qE "$pattern" "$ROOT_DIR/$file" 2>/dev/null; then
    echo "FAIL: $file requires $pattern"
    failed=1
  fi
done

# AI_GUIDE.md special rule: schema-field restatements are legal ONLY when the
# hit line carries an explicit OBSOLETE/已被取代 marker (dated historical
# record). Any unmarked restatement is drift.
while IFS= read -r hit; do
  line_text="${hit#*:}"
  if ! echo "$line_text" | grep -qE "OBSOLETE|已被取代"; then
    echo "FAIL: AI_GUIDE.md line ${hit%%:*} restates schema fields without OBSOLETE marker"
    failed=1
  fi
done < <(grep -nE "Role / Goal|Scope / Constraints|Expected Output" "$ROOT_DIR/AI_GUIDE.md" 2>/dev/null || true)

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "PASS: doc drift audit"
exit 0
