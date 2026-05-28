#!/usr/bin/env bash
set -euo pipefail
# Check whether the session-governance plugin was loaded by inspecting its receipt.
# The plugin writes outputs/runtime/plugin-loaded-receipt.json on startup.

RECEIPT="${1:-~/.config/opencode/outputs/runtime/plugin-loaded-receipt.json}"
RECEIPT="${RECEIPT/#\~/$HOME}"

if [[ ! -f "$RECEIPT" ]]; then
    echo "FAIL: plugin receipt not found at $RECEIPT"
    echo "  The session-governance plugin may not have been loaded."
    echo "  Restart OpenCode and re-run this check."
    exit 1
fi

AGE_SEC=$(($(date +%s) - $(stat -c %Y "$RECEIPT" 2>/dev/null || stat -f %m "$RECEIPT" 2>/dev/null)))
AGE_MIN=$((AGE_SEC / 60))

echo "OK: plugin receipt found (age: ${AGE_MIN}m ago)"
echo "  $(cat "$RECEIPT")"

# warn if receipt is older than 1 day
if [[ $AGE_MIN -gt 1440 ]]; then
    echo "WARN: receipt is over 24h old — plugin may not be loaded in the current session"
fi
