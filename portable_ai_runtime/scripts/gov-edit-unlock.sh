#!/usr/bin/env bash
set -euo pipefail

TASK_FILE="${HOME}/.config/opencode/CURRENT_TASK.md"
ROOT_DIR="${HOME}/.config/opencode"
TOKENIZER="zazaki_tokenizer"
MAX_INJECTED=4000

if [ ! -f "$TASK_FILE" ]; then
  echo "ERROR: ${TASK_FILE} does not exist."
  exit 1
fi

# ── Token budget pre-check ───────────────────────────────────────
if command -v "$TOKENIZER" &>/dev/null; then
  total=0
  for f in \
    "$ROOT_DIR/rules/ai/routing-rules.md" \
    "$ROOT_DIR/rules/ai/task-closure.md" \
    "$ROOT_DIR/rules/ai/verification-rules.md"; do
    raw=$("$TOKENIZER" count -f "$f" 2>/dev/null) || raw="0"
    n=${raw%% *}
    total=$((total + n))
  done

  if [ "$total" -gt "$MAX_INJECTED" ]; then
    echo "WARNING: always-injected token budget exceeded ($total > $MAX_INJECTED)"
    echo "  Refusing to unlock until token budget is resolved."
    echo "  Run scripts/check-governance-tokens.sh for per-file breakdown."
    exit 1
  fi
  echo "Token budget OK: $total / $MAX_INJECTED always-injected tokens"
else
  echo "NOTE: zazaki_tokenizer not found, skipping token budget check"
fi

if grep -qF '[AAR_COMPLETE]' "$TASK_FILE"; then
  echo "Already unlocked (AAR_COMPLETE marker present)."
  exit 0
fi

sed -i '1s/^\(<!-- ai-generated.*-->\)/\1\n[AAR_COMPLETE]/' "$TASK_FILE"

echo "Governance edit unlocked: [AAR_COMPLETE] marker added to CURRENT_TASK.md"
echo "Remember to run scripts/gov-edit-lock.sh after completing governance changes."
