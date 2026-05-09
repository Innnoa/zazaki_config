#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
RUNTIME_PACK_DIR="$SCRIPT_DIR/portable_dotcodex"

MODE="${1:-}"
TARGET_CODEX_HOME="${2:-$HOME/.codex}"
INIT_STATE="false"

if [[ "$MODE" == "install" && "${3:-}" == "--init-state" ]]; then
  INIT_STATE="true"
fi

if [[ "$MODE" != "install" && "$MODE" != "update" ]]; then
  printf 'usage:\n'
  printf '  %s install [target_dir] [--init-state]\n' "$0"
  printf '  %s update [target_dir]\n' "$0"
  exit 1
fi

copy_runtime_pack() {
  mkdir -p "$TARGET_CODEX_HOME"
  cp -R "$RUNTIME_PACK_DIR/." "$TARGET_CODEX_HOME/"
}

init_state_files() {
  [[ -f "$TARGET_CODEX_HOME/AI_GUIDE.md" ]] || cp "$TARGET_CODEX_HOME/state-templates/AI_GUIDE.template.md" "$TARGET_CODEX_HOME/AI_GUIDE.md"
  [[ -f "$TARGET_CODEX_HOME/CURRENT_TASK.md" ]] || cp "$TARGET_CODEX_HOME/state-templates/CURRENT_TASK.template.md" "$TARGET_CODEX_HOME/CURRENT_TASK.md"
  [[ -f "$TARGET_CODEX_HOME/DECISIONS.md" ]] || cp "$TARGET_CODEX_HOME/state-templates/DECISIONS.template.md" "$TARGET_CODEX_HOME/DECISIONS.md"
  mkdir -p "$TARGET_CODEX_HOME/handoff"
  [[ -f "$TARGET_CODEX_HOME/handoff/TEMPLATE.md" ]] || cp "$RUNTIME_PACK_DIR/handoff/TEMPLATE.md" "$TARGET_CODEX_HOME/handoff/TEMPLATE.md"
}

if [[ "$MODE" == "install" ]]; then
  printf 'installing portable runtime pack to %s\n' "$TARGET_CODEX_HOME"
  copy_runtime_pack

  if [[ ! -f "$TARGET_CODEX_HOME/config.toml" ]]; then
    cp "$TARGET_CODEX_HOME/config.template.toml" "$TARGET_CODEX_HOME/config.toml"
    printf 'created %s/config.toml from template\n' "$TARGET_CODEX_HOME"
  else
    printf 'kept existing %s/config.toml\n' "$TARGET_CODEX_HOME"
  fi

  if [[ "$INIT_STATE" == "true" ]]; then
    init_state_files
    printf 'initialized state files from templates when missing\n'
  fi

  printf 'next:\n'
  printf '1. edit %s/config.toml and replace placeholder values\n' "$TARGET_CODEX_HOME"
  printf '2. review %s/AGENTS.md and the files under rules/ai, workflows/ai, references/ai\n' "$TARGET_CODEX_HOME"
  printf '3. if needed, initialize AI_GUIDE.md, CURRENT_TASK.md, DECISIONS.md from state-templates\n'
  exit 0
fi

printf 'updating portable runtime governance in %s\n' "$TARGET_CODEX_HOME"
printf 'this updates runtime pack files and preserves live state files plus config.toml\n'

mkdir -p "$TARGET_CODEX_HOME"

cp "$RUNTIME_PACK_DIR/AGENTS.md" "$TARGET_CODEX_HOME/AGENTS.md"
mkdir -p "$TARGET_CODEX_HOME/rules/ai" "$TARGET_CODEX_HOME/workflows/ai" "$TARGET_CODEX_HOME/references/ai" "$TARGET_CODEX_HOME/state-templates" "$TARGET_CODEX_HOME/docs/governance"
cp -R "$RUNTIME_PACK_DIR/rules/ai/." "$TARGET_CODEX_HOME/rules/ai/"
cp -R "$RUNTIME_PACK_DIR/workflows/ai/." "$TARGET_CODEX_HOME/workflows/ai/"
cp -R "$RUNTIME_PACK_DIR/references/ai/." "$TARGET_CODEX_HOME/references/ai/"
cp -R "$RUNTIME_PACK_DIR/state-templates/." "$TARGET_CODEX_HOME/state-templates/"
cp -R "$RUNTIME_PACK_DIR/docs/governance/." "$TARGET_CODEX_HOME/docs/governance/"

if [[ ! -f "$TARGET_CODEX_HOME/config.toml" && -f "$TARGET_CODEX_HOME/config.template.toml" ]]; then
  cp "$TARGET_CODEX_HOME/config.template.toml" "$TARGET_CODEX_HOME/config.toml"
  printf 'created %s/config.toml from template\n' "$TARGET_CODEX_HOME"
else
  printf 'preserved existing config.toml if present\n'
fi

printf 'next:\n'
printf '1. review updated AGENTS.md, rules/ai, workflows/ai, references/ai\n'
printf '2. confirm local live state files still reflect your current machine context\n'
printf '3. edit %s/config.toml only if runtime provider or local paths changed\n' "$TARGET_CODEX_HOME"
