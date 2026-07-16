#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PACK_DIR="$SCRIPT_DIR"

# ── usage ──────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
用法:
  install.sh opencode  install [目标目录] [--init-state] [--dry-run]
  install.sh opencode  update  [目标目录] [--dry-run]
  install.sh codex     install [目标目录] [--init-state] [--dry-run]
  install.sh codex     update  [目标目录] [--dry-run]
  install.sh cursor    install [项目目录] [--dry-run]
  install.sh claude    install [项目目录] [--dry-run]
  install.sh copilot   install [项目目录] [--dry-run]

目标类型:
  opencode → AI governance for OpenCode CLI
  codex    → AI governance for Codex CLI
  cursor   → project-level Cursor rules
  claude   → project-level Claude Code rules
  copilot  → project-level GitHub Copilot instructions

默认目标目录:
  opencode → ~/.config/opencode
  codex    → ~/.codex
  cursor   → 当前工作目录
  claude   → 当前工作目录
  copilot  → 当前工作目录
EOF
  exit 1
}

# ── arg parsing ────────────────────────────────────────────────────────

TARGET_TYPE="${1:-}"
MODE="${2:-}"

valid_types="opencode codex cursor claude copilot"
valid_for_type() { [[ " $valid_types " == *" $1 "* ]]; }
valid_for_type "$TARGET_TYPE" || usage

if [[ "$TARGET_TYPE" =~ ^(opencode|codex)$ ]]; then
  [[ "$MODE" == "install" || "$MODE" == "update" ]] || usage
else
  MODE="install"
fi

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
  case "$TARGET_TYPE" in
    opencode) TARGET_DIR="$HOME/.config/opencode" ;;
    codex)    TARGET_DIR="$HOME/.codex" ;;
    *)        TARGET_DIR="$PWD" ;;
  esac
fi

# ── helpers ────────────────────────────────────────────────────────────

safe_copy_dir() { mkdir -p "$2"; cp -R "$1/." "$2/"; }
copy_if_missing() { [[ -f "$2" ]] || cp "$1" "$2"; }
safe_link_dir() { [[ -L "$2" || -d "$2" ]] && rm -rf "$2"; ln -s "$1" "$2"; }

# ── core rule dirs (shared across all tools) ───────────────────────────

CORE_DIRS=(rules workflows references skills scripts templates)
CORE_FILES=(AGENTS.md)

copy_core() {
  local dest="$1"
  printf '  安装核心治理规则...\n'
  for d in "${CORE_DIRS[@]}"; do
    if [[ -d "$PACK_DIR/$d" ]]; then
      safe_copy_dir "$PACK_DIR/$d" "$dest/$d"
      printf '    已复制: %s\n' "$d"
    fi
  done
  for f in "${CORE_FILES[@]}"; do
    if [[ -f "$PACK_DIR/$f" ]]; then
      cp "$PACK_DIR/$f" "$dest/$f"
      printf '    已复制: %s\n' "$f"
    fi
  done
  if [[ -d "$PACK_DIR/state-templates" ]]; then
    safe_copy_dir "$PACK_DIR/state-templates" "$dest/state-templates"
  fi
  if [[ -d "$PACK_DIR/handoff" ]]; then
    safe_copy_dir "$PACK_DIR/handoff" "$dest/handoff"
  fi
  if [[ -d "$PACK_DIR/templates" ]]; then
    safe_copy_dir "$PACK_DIR/templates" "$dest/templates"
  fi
}

# ── symlink-based install (project-level adapters) ─────────────────────

symlink_core() {
  local dest="$1"
  printf '  链接核心治理规则...\n'
  for d in "${CORE_DIRS[@]}"; do
    if [[ -d "$PACK_DIR/$d" ]]; then
      safe_link_dir "$PACK_DIR/$d" "$dest/$d"
      printf '    已链接: %s\n' "$d"
    fi
  done
  for f in "${CORE_FILES[@]}"; do
    if [[ -f "$PACK_DIR/$f" ]]; then
      safe_link_dir "$PACK_DIR/$f" "$dest/$f"
      printf '    已链接: %s\n' "$f"
    fi
  done
}

install_all() {
  mkdir -p "$TARGET_DIR"

  case "$TARGET_TYPE" in
    opencode)
      copy_core "$TARGET_DIR"
      printf '  安装 OpenCode 配置...\n'
      safe_copy_dir "$PACK_DIR/opencode/agents"    "$TARGET_DIR/agents"
      safe_copy_dir "$PACK_DIR/opencode/commands"   "$TARGET_DIR/commands"
      safe_copy_dir "$PACK_DIR/opencode/plugins"    "$TARGET_DIR/plugins"
      safe_copy_dir "$PACK_DIR/opencode/prompts"    "$TARGET_DIR/prompts"
      safe_copy_dir "$PACK_DIR/opencode/mcp"        "$TARGET_DIR/mcp"
      cp "$PACK_DIR/opencode/opencode.template.jsonc" "$TARGET_DIR/opencode.template.jsonc"
      if [[ ! -f "$TARGET_DIR/opencode.json" ]]; then
        cp "$TARGET_DIR/opencode.template.jsonc" "$TARGET_DIR/opencode.json"
        printf '    从模板创建: opencode.json\n'
      else
        printf '    保留已有: opencode.json\n'
      fi
      cp "$PACK_DIR/opencode/gitignore.template" "$TARGET_DIR/gitignore.template"
      if [[ ! -f "$TARGET_DIR/.gitignore" ]]; then
        cp "$PACK_DIR/opencode/gitignore.template" "$TARGET_DIR/.gitignore"
        printf '    从模板创建: .gitignore\n'
      fi
      ;;
    codex)
      copy_core "$TARGET_DIR"
      printf '  安装 Codex 配置...\n'
      cp "$PACK_DIR/adapters/codex/config.template.toml" "$TARGET_DIR/config.template.toml"
      cp "$PACK_DIR/adapters/codex/settings.json"       "$TARGET_DIR/settings.json"
      if [[ ! -f "$TARGET_DIR/config.toml" ]]; then
        cp "$PACK_DIR/adapters/codex/config.template.toml" "$TARGET_DIR/config.toml"
        printf '    从模板创建: config.toml\n'
      else
        printf '    保留已有: config.toml\n'
      fi
      ;;
    cursor)
      cp "$PACK_DIR/adapters/cursor/.cursorrules" "$TARGET_DIR/.cursorrules"
      symlink_core "$TARGET_DIR"
      echo -e "\n# AI governance symlinks (managed by portable_ai_runtime)\n${CORE_DIRS[*]}" >> "$TARGET_DIR/.gitignore" 2>/dev/null || true
      printf '  已安装: .cursorrules + 核心规则 (符号链接)\n'
      ;;
    claude)
      cp "$PACK_DIR/adapters/claude-code/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
      symlink_core "$TARGET_DIR"
      echo -e "\n# AI governance symlinks (managed by portable_ai_runtime)\n${CORE_DIRS[*]}" >> "$TARGET_DIR/.gitignore" 2>/dev/null || true
      printf '  已安装: CLAUDE.md + 核心规则 (符号链接)\n'
      ;;
    copilot)
      mkdir -p "$TARGET_DIR/.github"
      cp "$PACK_DIR/adapters/copilot/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
      symlink_core "$TARGET_DIR"
      echo -e "\n# AI governance symlinks (managed by portable_ai_runtime)\n${CORE_DIRS[*]}" >> "$TARGET_DIR/.gitignore" 2>/dev/null || true
      printf '  已安装: .github/copilot-instructions.md + 核心规则 (符号链接)\n'
      ;;
  esac
}

install_dry_run() {
  cat <<DRY

═══════════════════════════════════════
  dry-run 模式：不会写入任何文件
═══════════════════════════════════════

  目标类型   : $TARGET_TYPE
  目标目录   : $TARGET_DIR
  pack 源    : $PACK_DIR

  将安装核心治理规则和 $TARGET_TYPE 适配器。
  （opencode/codex 使用文件复制，cursor/claude/copilot 使用符号链接）
DRY
  printf '\n'
}

# ── update (opencode / codex only) ─────────────────────────────────────

LIVE_STATE_FILES=(AI_GUIDE.md CURRENT_TASK.md DECISIONS.md)

update_all() {
  mkdir -p "$TARGET_DIR"

  printf '  更新核心治理规则与工作流...\n'
  for d in "${CORE_DIRS[@]}"; do
    if [[ -d "$PACK_DIR/$d" ]]; then
      safe_copy_dir "$PACK_DIR/$d" "$TARGET_DIR/$d"
    fi
  done
  cp "$PACK_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"

  printf '  更新工具适配器...\n'
  case "$TARGET_TYPE" in
    opencode)
      safe_copy_dir "$PACK_DIR/opencode/agents"  "$TARGET_DIR/agents"
      safe_copy_dir "$PACK_DIR/opencode/commands" "$TARGET_DIR/commands"
      safe_copy_dir "$PACK_DIR/opencode/plugins"  "$TARGET_DIR/plugins"
      cp "$PACK_DIR/opencode/opencode.template.jsonc" "$TARGET_DIR/opencode.template.jsonc"
      cp "$PACK_DIR/opencode/gitignore.template" "$TARGET_DIR/gitignore.template"
      ;;
    codex)
      cp "$PACK_DIR/adapters/codex/config.template.toml" "$TARGET_DIR/config.template.toml"
      cp "$PACK_DIR/adapters/codex/settings.json"       "$TARGET_DIR/settings.json"
      ;;
  esac

  printf '  保留 live 状态文件（不覆盖）：\n'
  for f in "${LIVE_STATE_FILES[@]}"; do
    [[ -f "$TARGET_DIR/$f" ]] && printf '    %s\n' "$f"
  done
}

update_dry_run() {
  cat <<DRY

═══════════════════════════════════════
  dry-run 模式：不会写入任何文件
═══════════════════════════════════════

  目标类型   : $TARGET_TYPE
  目标目录   : $TARGET_DIR

  将更新核心规则和 $TARGET_TYPE 适配器。
  保留 live 状态文件 (AI_GUIDE.md, CURRENT_TASK.md, DECISIONS.md)。
DRY
  printf '\n'
}

# ── state initialization ───────────────────────────────────────────────

init_state_files() {
  printf '  初始化状态文件（缺失时从模板创建）...\n'
  local tpl="$TARGET_DIR/state-templates"
  copy_if_missing "$tpl/AI_GUIDE.template.md"     "$TARGET_DIR/AI_GUIDE.md"     && printf '    AI_GUIDE.md\n'
  copy_if_missing "$tpl/CURRENT_TASK.template.md"  "$TARGET_DIR/CURRENT_TASK.md"  && printf '    CURRENT_TASK.md\n'
  copy_if_missing "$tpl/DECISIONS.template.md"     "$TARGET_DIR/DECISIONS.md"     && printf '    DECISIONS.md\n'
  [[ -d "$PACK_DIR/handoff" ]] && mkdir -p "$TARGET_DIR/handoff"
  copy_if_missing "$PACK_DIR/handoff/TEMPLATE.md"  "$TARGET_DIR/handoff/TEMPLATE.md"  && printf '    handoff/TEMPLATE.md\n' || true
  copy_if_missing "$PACK_DIR/handoff/_TEMPLATE.md" "$TARGET_DIR/handoff/_TEMPLATE.md" && printf '    handoff/_TEMPLATE.md\n' || true
}

# ── post-install hints ─────────────────────────────────────────────────

post_install_hints() {
  printf '\n════════════ 后续步骤 ════════════\n'
  case "$TARGET_TYPE" in
    opencode)
      printf '1. 编辑 %s/opencode.json\n' "$TARGET_DIR"
      printf '   替换 {env:VAR} 占位符和 MCP 路径为本机实际值\n'
      ;;
    codex)
      printf '1. 编辑 %s/config.toml\n' "$TARGET_DIR"
      printf '   填入 token 与 provider 配置\n'
      ;;
    cursor)
      printf '1. 查看 %s/.cursorrules\n' "$TARGET_DIR"
      printf '2. 重启 Cursor 使其生效\n'
      printf '\n核心规则通过符号链接引用，更新仓库即自动同步到本项目。\n'
      ;;
    claude)
      printf '1. 查看 %s/CLAUDE.md\n' "$TARGET_DIR"
      printf '2. 重启 Claude Code 使其生效\n'
      printf '\n核心规则通过符号链接引用，更新仓库即自动同步到本项目。\n'
      ;;
    copilot)
      printf '1. 查看 %s/.github/copilot-instructions.md\n' "$TARGET_DIR"
      printf '2. 提交到 Git 仓库使 GitHub Copilot 生效\n'
      printf '\n核心规则通过符号链接引用，更新仓库即自动同步到本项目。\n'
      ;;
  esac
  [[ "$INIT_STATE" != "true" ]] && printf '3. 如需初始化状态文件，追加 --init-state 重新运行\n'
}

post_update_hints() {
  printf '\n════════════ 后续步骤 ════════════\n'
  printf '1. 检查更新后的 AGENTS.md 与规则文件\n'
  printf '2. 确认 live 状态文件仍正确\n'
}

# ── main ───────────────────────────────────────────────────────────────

if [[ "$DRY_RUN" == "true" ]]; then
  [[ "$MODE" == "update" ]] && update_dry_run || install_dry_run
  exit 0
fi

if [[ "$MODE" == "update" ]]; then
  if [[ ! -d "$TARGET_DIR" ]]; then
    printf '目标目录不存在，执行全新安装\n'
    install_all
  else
    printf '════════════════════════════════════\n'
    printf '更新 portable runtime governance\n'
    printf '  目标: %s (%s)\n' "$TARGET_DIR" "$TARGET_TYPE"
    printf '════════════════════════════════════\n'
    update_all
    printf '\n更新完成。\n'
    post_update_hints
    exit 0
  fi
else
  printf '════════════════════════════════════\n'
  printf '安装 portable runtime pack\n'
  printf '  目标: %s (%s)\n' "$TARGET_DIR" "$TARGET_TYPE"
  printf '════════════════════════════════════\n'
  install_all
fi

if [[ "$INIT_STATE" == "true" ]]; then
  init_state_files
fi

printf '\n安装完成。\n'
post_install_hints
