#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PACK_DIR="$SCRIPT_DIR/portable_dotcodex"

# ── usage ──────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
用法:
  install.sh opencode install [目标目录] [--init-state] [--dry-run]
  install.sh opencode update  [目标目录] [--dry-run]
  install.sh codex    install [目标目录] [--init-state] [--dry-run]
  install.sh codex    update  [目标目录] [--dry-run]

默认目标目录:
  opencode → ~/.config/opencode
  codex    → ~/.codex
EOF
  exit 1
}

# ── arg parsing ────────────────────────────────────────────────────────

TARGET_TYPE="${1:-}"
MODE="${2:-}"

[[ "$TARGET_TYPE" == "opencode" || "$TARGET_TYPE" == "codex" ]] || usage
[[ "$MODE" == "install" || "$MODE" == "update"   ]] || usage

TARGET_DIR=""
INIT_STATE="false"
DRY_RUN="false"

for arg in "${@:3}"; do
  case "$arg" in
    --init-state) INIT_STATE="true" ;;
    --dry-run)    DRY_RUN="true"    ;;
    -*)           printf '未知选项: %s\n' "$arg"; usage ;;
    *)            TARGET_DIR="$arg"  ;;
  esac
done

if [[ -z "$TARGET_DIR" ]]; then
  if [[ "$TARGET_TYPE" == "opencode" ]]; then
    TARGET_DIR="$HOME/.config/opencode"
  else
    TARGET_DIR="$HOME/.codex"
  fi
fi

if [[ "$TARGET_TYPE" == "opencode" ]]; then
  CONFIG_TEMPLATE="opencode.template.jsonc"
  CONFIG_FILE="opencode.json"
else
  CONFIG_TEMPLATE="config.template.toml"
  CONFIG_FILE="config.toml"
fi

# ── helpers ────────────────────────────────────────────────────────────

safe_copy()      { mkdir -p "$(dirname "$2")"; cp -R "$1" "$2"; }
safe_copy_dir()  { mkdir -p "$2"; cp -R "$1/." "$2/"; }
copy_if_missing() { [[ -f "$2" ]] || cp "$1" "$2"; }

# ── install ────────────────────────────────────────────────────────────

install_all() {
  mkdir -p "$TARGET_DIR"

  local dirs=(
    agents commands scripts skills
    rules/ai workflows/ai references/ai
    mcp prompts templates plugins
    state-templates handoff
    docs/governance docs/plans docs/requirements
  )

  local ok=0
  for d in "${dirs[@]}"; do
    if [[ -d "$PACK_DIR/$d" ]]; then
      safe_copy_dir "$PACK_DIR/$d" "$TARGET_DIR/$d"
      printf '  已复制: %s\n' "$d"
      ok=$((ok + 1))
    fi
  done

  local files=(
    AGENTS.md
    "$CONFIG_TEMPLATE"
    settings.json
    gitignore.template
  )
  for f in "${files[@]}"; do
    if [[ -f "$PACK_DIR/$f" ]]; then
      cp "$PACK_DIR/$f" "$TARGET_DIR/$f"
      printf '  已复制: %s\n' "$f"
    fi
  done

  if [[ ! -f "$TARGET_DIR/$CONFIG_FILE" && -f "$TARGET_DIR/$CONFIG_TEMPLATE" ]]; then
    cp "$TARGET_DIR/$CONFIG_TEMPLATE" "$TARGET_DIR/$CONFIG_FILE"
    printf '  从模板创建: %s → %s\n' "$CONFIG_TEMPLATE" "$CONFIG_FILE"
  elif [[ -f "$TARGET_DIR/$CONFIG_FILE" ]]; then
    printf '  保留已有: %s（不覆盖）\n' "$CONFIG_FILE"
  fi

  # Copy gitignore.template → .gitignore if not exists
  if [[ ! -f "$TARGET_DIR/.gitignore" && -f "$PACK_DIR/gitignore.template" ]]; then
    cp "$PACK_DIR/gitignore.template" "$TARGET_DIR/.gitignore"
    printf '  从模板创建: gitignore.template → .gitignore\n'
  fi
}

install_dry_run() {
  cat <<DRY

═══════════════════════════════════════════
  dry-run 模式：不会写入任何文件
═══════════════════════════════════════════

  目标类型   : $TARGET_TYPE
  目标目录   : $TARGET_DIR
  pack 源    : $PACK_DIR

  将复制以下内容：
    AGENTS.md
    ${CONFIG_TEMPLATE} → ${CONFIG_FILE}（仅在缺失时创建）
    settings.json
    agents/  commands/  scripts/  skills/  plugins/
    rules/ai/  workflows/ai/  references/ai/
    mcp/  prompts/  templates/
    state-templates/  handoff/
    docs/governance/  docs/plans/  docs/requirements/
    gitignore.template
DRY
  if [[ "$INIT_STATE" == "true" ]]; then
    printf '\n  将从模板初始化缺失的状态文件：\n'
    printf '    AI_GUIDE.md  CURRENT_TASK.md  DECISIONS.md  handoff/TEMPLATE.md\n'
  fi
  printf '\n'
}

# ── update ─────────────────────────────────────────────────────────────

LIVE_STATE_FILES=(
  AI_GUIDE.md
  CURRENT_TASK.md
  DECISIONS.md
)

update_all() {
  mkdir -p "$TARGET_DIR"

  printf '  更新治理规则与工作流...\n'
  local gov_dirs=(
    rules/ai workflows/ai references/ai
    agents commands scripts plugins
    state-templates docs/governance docs/plans docs/requirements
  )
  for d in "${gov_dirs[@]}"; do
    if [[ -d "$PACK_DIR/$d" ]]; then
      safe_copy_dir "$PACK_DIR/$d" "$TARGET_DIR/$d"
    fi
  done

  printf '  更新技能...\n'
  if [[ -d "$PACK_DIR/skills" ]]; then
    mkdir -p "$TARGET_DIR/skills"
    for skill in "$PACK_DIR/skills/"*; do
      skill_name="$(basename "$skill")"
      if [[ -d "$TARGET_DIR/skills/$skill_name" ]]; then
        rm -rf "$TARGET_DIR/skills/$skill_name"
      fi
      cp -R "$skill" "$TARGET_DIR/skills/$skill_name"
    done
  fi

  printf '  更新 MCP 配置...\n'
  [[ -d "$PACK_DIR/mcp" ]] && safe_copy_dir "$PACK_DIR/mcp" "$TARGET_DIR/mcp"

  printf '  更新 prompts 与 templates...\n'
  for d in prompts templates; do
    if [[ -d "$TARGET_DIR/$d" ]]; then
      rm -rf "$TARGET_DIR/$d"
    fi
    [[ -d "$PACK_DIR/$d" ]] && safe_copy_dir "$PACK_DIR/$d" "$TARGET_DIR/$d"
  done

  local files=(AGENTS.md settings.json "$CONFIG_TEMPLATE" gitignore.template)
  for f in "${files[@]}"; do
    [[ -f "$PACK_DIR/$f" ]] && cp "$PACK_DIR/$f" "$TARGET_DIR/$f"
  done

  if [[ ! -f "$TARGET_DIR/$CONFIG_FILE" && -f "$TARGET_DIR/$CONFIG_TEMPLATE" ]]; then
    cp "$TARGET_DIR/$CONFIG_TEMPLATE" "$TARGET_DIR/$CONFIG_FILE"
    printf '  从模板创建: %s → %s\n' "$CONFIG_TEMPLATE" "$CONFIG_FILE"
  fi

  # Copy .gitignore if not exists
  if [[ ! -f "$TARGET_DIR/.gitignore" && -f "$PACK_DIR/gitignore.template" ]]; then
    cp "$PACK_DIR/gitignore.template" "$TARGET_DIR/.gitignore"
    printf '  从模板创建: .gitignore\n'
  fi

  if [[ -f "$PACK_DIR/handoff/TEMPLATE.md" ]]; then
    mkdir -p "$TARGET_DIR/handoff"
    cp "$PACK_DIR/handoff/TEMPLATE.md" "$TARGET_DIR/handoff/TEMPLATE.md"
  fi
  if [[ -f "$PACK_DIR/handoff/_TEMPLATE.md" ]]; then
    mkdir -p "$TARGET_DIR/handoff"
    cp "$PACK_DIR/handoff/_TEMPLATE.md" "$TARGET_DIR/handoff/_TEMPLATE.md"
  fi

  printf '  保留 live 状态文件（不覆盖）：\n'
  for f in "${LIVE_STATE_FILES[@]}"; do
    if [[ -f "$TARGET_DIR/$f" ]]; then
      printf '    %s\n' "$f"
    fi
  done
}

update_dry_run() {
  cat <<DRY

═══════════════════════════════════════════
  dry-run 模式：不会写入任何文件
═══════════════════════════════════════════

  目标类型   : $TARGET_TYPE
  目标目录   : $TARGET_DIR
  pack 源    : $PACK_DIR

  将更新（覆盖）：
    AGENTS.md  settings.json  ${CONFIG_TEMPLATE}  gitignore.template
    agents/  commands/  scripts/  plugins/
    skills/（pack 中的所有技能）
    rules/ai/  workflows/ai/  references/ai/
    mcp/  prompts/  templates/
    state-templates/  handoff/TEMPLATE.md  handoff/_TEMPLATE.md
    docs/governance/  docs/plans/  docs/requirements/

  将保留（永不覆盖）：
    ${CONFIG_FILE}
    AI_GUIDE.md  CURRENT_TASK.md  DECISIONS.md
    handoff/*（TEMPLATE.md 除外）
DRY
  printf '\n'
}

# ── state initialization (install only) ────────────────────────────────

init_state_files() {
  printf '  初始化状态文件（缺失时从模板创建）...\n'
  local tpl="$TARGET_DIR/state-templates"
  copy_if_missing "$tpl/AI_GUIDE.template.md"     "$TARGET_DIR/AI_GUIDE.md"     && printf '    AI_GUIDE.md\n'
  copy_if_missing "$tpl/CURRENT_TASK.template.md"  "$TARGET_DIR/CURRENT_TASK.md"  && printf '    CURRENT_TASK.md\n'
  copy_if_missing "$tpl/DECISIONS.template.md"     "$TARGET_DIR/DECISIONS.md"     && printf '    DECISIONS.md\n'
  mkdir -p "$TARGET_DIR/handoff"
  copy_if_missing "$PACK_DIR/handoff/TEMPLATE.md"  "$TARGET_DIR/handoff/TEMPLATE.md" && printf '    handoff/TEMPLATE.md\n'
  copy_if_missing "$PACK_DIR/handoff/_TEMPLATE.md" "$TARGET_DIR/handoff/_TEMPLATE.md" && printf '    handoff/_TEMPLATE.md\n'
}

# ── post-install hints ─────────────────────────────────────────────────

post_install_hints() {
  printf '\n════════════ 后续步骤 ════════════\n'
  if [[ "$TARGET_TYPE" == "opencode" ]]; then
    printf '1. 编辑 %s/%s\n' "$TARGET_DIR" "$CONFIG_FILE"
    printf '   替换 {env:OPENAI_API_KEY} 和 ~/ 路径为本机实际值\n'
  else
    printf '1. 编辑 %s/%s\n' "$TARGET_DIR" "$CONFIG_FILE"
    printf '   填入 token、provider 与本机路径\n'
  fi
  printf '2. 阅读 %s/AGENTS.md 了解治理结构\n' "$TARGET_DIR"
  printf '3. 浏览 rules/ai/、workflows/ai/、references/ai/\n'
  if [[ "$INIT_STATE" != "true" ]]; then
    printf '4. 如需初始化状态文件，追加 --init-state 重新运行\n'
  fi
}

post_update_hints() {
  printf '\n════════════ 后续步骤 ════════════\n'
  printf '1. 检查更新后的 AGENTS.md 与规则文件\n'
  printf '2. 确认 live 状态文件 (AI_GUIDE.md, CURRENT_TASK.md, DECISIONS.md) 仍正确\n'
  if [[ "$TARGET_TYPE" == "opencode" ]]; then
    printf '3. 仅当 provider 或路径变更时才编辑 %s\n' "$CONFIG_FILE"
  fi
}

# ── main ───────────────────────────────────────────────────────────────

if [[ "$MODE" == "install" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    install_dry_run
    exit 0
  fi
  printf '════════════════════════════════════\n'
  printf '安装 portable runtime pack\n'
  printf '  目标: %s (%s)\n' "$TARGET_DIR" "$TARGET_TYPE"
  printf '════════════════════════════════════\n'
  install_all
  if [[ "$INIT_STATE" == "true" ]]; then
    init_state_files
  fi
  printf '\n安装完成。\n'
  post_install_hints
else
  if [[ "$DRY_RUN" == "true" ]]; then
    update_dry_run
    exit 0
  fi

  if [[ ! -d "$TARGET_DIR" ]]; then
    printf '════════════════════════════════════\n'
    printf '目标目录不存在，执行全新安装\n'
    printf '  目标: %s (%s)\n' "$TARGET_DIR" "$TARGET_TYPE"
    printf '════════════════════════════════════\n'
    install_all
    if [[ "$INIT_STATE" == "true" ]]; then
      init_state_files
    fi
    printf '\n安装完成。\n'
    post_install_hints
  else
    printf '════════════════════════════════════\n'
    printf '更新 portable runtime governance\n'
    printf '  目标: %s (%s)\n' "$TARGET_DIR" "$TARGET_TYPE"
    printf '════════════════════════════════════\n'
    update_all
    printf '\n更新完成。\n'
    post_update_hints
  fi
fi
