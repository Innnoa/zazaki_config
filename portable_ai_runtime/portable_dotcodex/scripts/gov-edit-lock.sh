#!/usr/bin/env bash
set -euo pipefail

TASK_FILE="${HOME}/.config/opencode/CURRENT_TASK.md"

if [ ! -f "$TASK_FILE" ]; then
  echo "ERROR: ${TASK_FILE} does not exist."
  exit 1
fi

if ! grep -qF '[AAR_COMPLETE]' "$TASK_FILE"; then
  echo "Already locked (no AAR_COMPLETE marker)."
  exit 0
fi

sed -i '/^\[AAR_COMPLETE\]$/d' "$TASK_FILE"

echo "Governance edit locked: [AAR_COMPLETE] marker removed from CURRENT_TASK.md"
