#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
TARGET_CODEX_HOME="${1:-$HOME/.codex}"

mkdir -p "$TARGET_CODEX_HOME"
cp -R "$SCRIPT_DIR/portable_dotcodex/." "$TARGET_CODEX_HOME/"

if [[ ! -f "$TARGET_CODEX_HOME/config.toml" ]]; then
  cp "$TARGET_CODEX_HOME/config.template.toml" "$TARGET_CODEX_HOME/config.toml"
  printf 'created %s/config.toml from template\n' "$TARGET_CODEX_HOME"
else
  printf 'kept existing %s/config.toml\n' "$TARGET_CODEX_HOME"
fi

printf 'next:\n'
printf '1. edit %s/config.toml and replace placeholder values\n' "$TARGET_CODEX_HOME"
printf '2. review %s/settings.json if you use VCO intent advice\n' "$TARGET_CODEX_HOME"
printf '3. initialize AI_GUIDE.md, CURRENT_TASK.md, DECISIONS.md from state-templates when needed\n'
