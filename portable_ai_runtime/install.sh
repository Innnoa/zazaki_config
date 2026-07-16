#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PACK_DIR="$SCRIPT_DIR"

# ── colors ─────────────────────────────────────────────────────────────

BOLD=$'\033[1m'
GREEN=$'\033[32m'
CYAN=$'\033[36m'
RESET=$'\033[0m'

# ── usage ──────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
用法:
  install.sh                                     # 交互模式
  install.sh opencode  install [--init-state]    # OpenCode CLI
  install.sh opencode  update
  install.sh codex     install [--init-state]    # Codex CLI
  install.sh codex     update
  install.sh cursor    install [~/.my-project]   # Cursor 规则
  install.sh claude    install [~/.my-project]   # Claude Code 规则
  install.sh copilot   install [~/.my-project]   # GitHub Copilot 规则

选项:
  --init-state  安装后从模板初始化 AI_GUIDE/CURRENT_TASK/DECISIONS
  --dry-run     预览模式，不写入文件
EOF
  exit 1
}

# ── arg parsing ────────────────────────────────────────────────────────

TARGET_TYPE=""
MODE=""
TARGET_DIR=""
INIT_STATE="false"
DRY_RUN="false"
INSTALL_METHOD=""

if [[ $# -gt 0 ]]; then
  TARGET_TYPE="${1:-}"
  MODE="${2:-}"
  for arg in "${@:3}"; do
    case "$arg" in
      --init-state) INIT_STATE="true" ;;
      --dry-run)    DRY_RUN="true"    ;;
      -*)           printf '未知选项: %s\n' "$arg"; usage ;;
      *)            TARGET_DIR="$arg"  ;;
    esac
  done
fi

# ── interactive mode ───────────────────────────────────────────────────

tool_default_dir() {
  case "$1" in
    opencode) echo "$HOME/.config/opencode" ;;
    codex)    echo "$HOME/.codex" ;;
    claude)   echo "$HOME/.claude" ;;
    *)        echo "$HOME" ;;
  esac
}

# Returns 0 if user selected a tool, 1 if exit
choose_tool() {
  echo -e "${BOLD}${CYAN}═══ Portable AI Runtime 安装 ${RESET}"
  while true; do
    echo ""
    PS3=$'\n请选择目标工具: '
    select tool in "OpenCode CLI" "Codex CLI" "Cursor Rules" "Claude Code Rules" "GitHub Copilot" "退出"; do
      case "$REPLY" in
        1) TARGET_TYPE="opencode"; return 0 ;;
        2) TARGET_TYPE="codex";    return 0 ;;
        3) TARGET_TYPE="cursor";   return 0 ;;
        4) TARGET_TYPE="claude";   return 0 ;;
        5) TARGET_TYPE="copilot";  return 0 ;;
        6) echo "已取消。"; exit 0 ;;
      esac
    done
  done
}

# Returns 0 if user selected install/update, 1 if "返回"
choose_mode() {
  while true; do
    echo ""
    PS3=$'\n选择操作: '
    select op in "安装 (新装)" "更新 (覆盖规则，保留配置)" "返回"; do
      case "$REPLY" in
        1) MODE="install"; return 0 ;;
        2) MODE="update";  return 0 ;;
        3) return 1 ;;
      esac
    done
  done
}

# Returns 0 if user selected global/project, 1 if "返回"
choose_scope() {
  local global_dir
  global_dir="$(tool_default_dir "$TARGET_TYPE")"

  while true; do
    echo ""
    printf '%s%s — 安装范围%s\n' "$BOLD" "$TARGET_TYPE" "$RESET"
    printf '  全局: 安装在 %s（所有项目共用，文件复制）\n' "$global_dir"
    printf '  项目: 指定项目目录（仅该项目生效，符号链接）\n'
    PS3=$'\n选择范围: '
    select sc in "全局安装" "项目安装" "返回"; do
      case "$REPLY" in
        1) TARGET_DIR="$global_dir"; INSTALL_METHOD="copy";   return 0 ;;
        2)
          while true; do
            read -r -p $'\n输入项目根目录路径: ' dir_input
            if [[ -n "$dir_input" ]]; then
              TARGET_DIR="$dir_input"
              INSTALL_METHOD="symlink"
              return 0
            fi
            echo "路径不能为空"
          done
          ;;
        3) return 1 ;;
      esac
    done
  done
}

interactive_menu() {
  while true; do
    # ── 1. 选工具 ──
    choose_tool

    # ── 2. 选范围 ──
    if ! choose_scope; then
      continue
    fi

    # ── 3. 初始化状态文件 (仅 opencode/codex) ──
    if [[ "$TARGET_TYPE" =~ ^(opencode|codex)$ ]]; then
      echo ""
      read -r -p "初始化状态文件? (AI_GUIDE/CURRENT_TASK/DECISIONS) [y/N]: " init_choice
      [[ "$init_choice" =~ ^[Yy]$ ]] && INIT_STATE="true"
    fi

    # ── 4. 确认 ──
    echo ""
    echo -e "${BOLD}确认安装:${RESET}"
    echo "  工具:     $TARGET_TYPE"
    echo "  目录:     $TARGET_DIR"
    echo "  方式:     $([[ "$INSTALL_METHOD" == "copy" ]] && echo "文件复制" || echo "符号链接")"
    [[ "$INIT_STATE" == "true" ]] && echo "  初始化:   是"
    read -r -p $'\n继续? [Y/n]: ' confirm
    [[ "$confirm" =~ ^[Nn]$ ]] && continue

    return 0
  done
}

# ── auto-detect defaults (non-interactive) ─────────────────────────────

if [[ -z "$TARGET_TYPE" ]]; then
  interactive_menu
fi

valid_types="opencode codex cursor claude copilot"
[[ " $valid_types " == *" $TARGET_TYPE "* ]] || usage

if [[ "$TARGET_TYPE" =~ ^(opencode|codex)$ ]]; then
  [[ "$MODE" == "install" || "$MODE" == "update" ]] || usage
else
  MODE="install"
fi

if [[ -z "$TARGET_DIR" ]]; then
  case "$TARGET_TYPE" in
    opencode) TARGET_DIR="$HOME/.config/opencode" ;;
    codex)    TARGET_DIR="$HOME/.codex" ;;
    claude)   TARGET_DIR="$HOME/.claude" ;;
    *)        TARGET_DIR="$HOME" ;;
  esac
fi

# 非交互模式下，项目工具默认符号链接，系统工具默认复制
if [[ -z "$INSTALL_METHOD" ]]; then
  if [[ "$TARGET_TYPE" =~ ^(cursor|claude|copilot)$ ]]; then
    INSTALL_METHOD="symlink"
  else
    INSTALL_METHOD="copy"
  fi
fi

# ── helpers ────────────────────────────────────────────────────────────

safe_copy_dir() { mkdir -p "$2"; cp -R "$1/." "$2/"; }
copy_if_missing() { [[ -f "$2" ]] || cp "$1" "$2"; }
safe_link_dir() { [[ -L "$2" || -d "$2" ]] && rm -rf "$2"; ln -s "$1" "$2"; }

CORE_DIRS=(rules workflows references skills scripts templates)
CORE_FILES=(AGENTS.md)

copy_core() {
  local dest="$1"
  printf '  %s复制核心治理规则...%s\n' "$GREEN" "$RESET"
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
}

symlink_core() {
  local dest="$1"
  printf '  %s链接核心治理规则（符号链接）...%s\n' "$GREEN" "$RESET"
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

# ── install ────────────────────────────────────────────────────────────

install_all() {
  mkdir -p "$TARGET_DIR"

  # ── 核心规则 (全局=复制, 项目=符号链接) ──
  if [[ "$INSTALL_METHOD" == "symlink" ]]; then
    symlink_core "$TARGET_DIR"
  else
    copy_core "$TARGET_DIR"
  fi

  # ── 工具特有文件 ──
  case "$TARGET_TYPE" in
    opencode)
      printf '  %s安装 OpenCode 配置...%s\n' "$GREEN" "$RESET"
      for d in agents commands plugins prompts mcp; do
        [[ -d "$PACK_DIR/opencode/$d" ]] && safe_copy_dir "$PACK_DIR/opencode/$d" "$TARGET_DIR/$d" && printf '    已复制: opencode/%s\n' "$d"
      done
      cp "$PACK_DIR/opencode/opencode.template.jsonc" "$TARGET_DIR/opencode.template.jsonc"
      cp "$PACK_DIR/opencode/gitignore.template" "$TARGET_DIR/gitignore.template"
      if [[ ! -f "$TARGET_DIR/opencode.json" ]]; then
        cp "$TARGET_DIR/opencode.template.jsonc" "$TARGET_DIR/opencode.json"
        printf '    %s从模板创建: opencode.json%s\n' "$GREEN" "$RESET"
      else
        printf '    保留已有: opencode.json\n'
      fi
      if [[ ! -f "$TARGET_DIR/.gitignore" ]]; then
        cp "$PACK_DIR/opencode/gitignore.template" "$TARGET_DIR/.gitignore"
        printf '    从模板创建: .gitignore\n'
      fi
      ;;
    codex)
      printf '  %s安装 Codex 配置...%s\n' "$GREEN" "$RESET"
      cp "$PACK_DIR/adapters/codex/config.template.toml" "$TARGET_DIR/config.template.toml"
      cp "$PACK_DIR/adapters/codex/settings.json"       "$TARGET_DIR/settings.json"
      if [[ ! -f "$TARGET_DIR/config.toml" ]]; then
        cp "$PACK_DIR/adapters/codex/config.template.toml" "$TARGET_DIR/config.toml"
        printf '    %s从模板创建: config.toml%s\n' "$GREEN" "$RESET"
      else
        printf '    保留已有: config.toml\n'
      fi
      ;;
    cursor)
      cp "$PACK_DIR/adapters/cursor/.cursorrules" "$TARGET_DIR/.cursorrules"
      if [[ "$INSTALL_METHOD" == "symlink" ]]; then
        echo -e "\n# AI governance symlinks\n${CORE_DIRS[*]}" >> "$TARGET_DIR/.gitignore" 2>/dev/null || true
      fi
      printf '\n  %s已安装: .cursorrules + 核心规则%s\n' "$BOLD" "$RESET"
      ;;
    claude)
      cp "$PACK_DIR/adapters/claude-code/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
      if [[ "$INSTALL_METHOD" == "symlink" ]]; then
        echo -e "\n# AI governance symlinks\n${CORE_DIRS[*]}" >> "$TARGET_DIR/.gitignore" 2>/dev/null || true
      fi
      printf '\n  %s已安装: CLAUDE.md + 核心规则%s\n' "$BOLD" "$RESET"
      ;;
    copilot)
      mkdir -p "$TARGET_DIR/.github"
      cp "$PACK_DIR/adapters/copilot/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
      if [[ "$INSTALL_METHOD" == "symlink" ]]; then
        echo -e "\n# AI governance symlinks\n${CORE_DIRS[*]}" >> "$TARGET_DIR/.gitignore" 2>/dev/null || true
      fi
      printf '\n  %s已安装: .github/copilot-instructions.md + 核心规则%s\n' "$BOLD" "$RESET"
      ;;
  esac
}

install_dry_run() {
  cat <<DRY

═══════════════════════════════════════
  dry-run 模式 — 不会写入任何文件
═══════════════════════════════════════

  工具:     $TARGET_TYPE
  目标目录: $TARGET_DIR
  pack 源:  $PACK_DIR

  $( [[ "$INSTALL_METHOD" == "symlink" ]] && echo "安装方式: 符号链接（更新仓库即同步）" || echo "安装方式: 文件复制" )
DRY
  printf '\n'
}

# ── update (opencode / codex only) ─────────────────────────────────────

LIVE_STATE_FILES=(AI_GUIDE.md CURRENT_TASK.md DECISIONS.md)

update_all() {
  mkdir -p "$TARGET_DIR"
  printf '  %s更新核心规则...%s\n' "$GREEN" "$RESET"
  for d in "${CORE_DIRS[@]}"; do
    [[ -d "$PACK_DIR/$d" ]] && safe_copy_dir "$PACK_DIR/$d" "$TARGET_DIR/$d"
  done
  cp "$PACK_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"

  printf '  %s更新工具适配器...%s\n' "$GREEN" "$RESET"
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

  printf '  保留 live 状态文件（不覆盖）:\n'
  for f in "${LIVE_STATE_FILES[@]}"; do
    [[ -f "$TARGET_DIR/$f" ]] && printf '    %s\n' "$f"
  done
}

update_dry_run() {
  cat <<DRY

═══════════════════════════════════════
  dry-run 模式 — 不会写入任何文件
═══════════════════════════════════════

  工具:     $TARGET_TYPE
  目标目录: $TARGET_DIR

  将更新核心规则和 $TARGET_TYPE 适配器。
  保留: AI_GUIDE.md, CURRENT_TASK.md, DECISIONS.md
DRY
  printf '\n'
}

# ── state initialization ───────────────────────────────────────────────

init_state_files() {
  printf '  %s初始化状态文件（缺失时创建）...%s\n' "$GREEN" "$RESET"
  local tpl="$TARGET_DIR/state-templates"
  [[ -d "$PACK_DIR/state-templates" ]] && safe_copy_dir "$PACK_DIR/state-templates" "$TARGET_DIR/state-templates"
  copy_if_missing "$tpl/AI_GUIDE.template.md"     "$TARGET_DIR/AI_GUIDE.md"     && printf '    AI_GUIDE.md\n'
  copy_if_missing "$tpl/CURRENT_TASK.template.md"  "$TARGET_DIR/CURRENT_TASK.md"  && printf '    CURRENT_TASK.md\n'
  copy_if_missing "$tpl/DECISIONS.template.md"     "$TARGET_DIR/DECISIONS.md"     && printf '    DECISIONS.md\n'
  [[ -d "$PACK_DIR/handoff" ]] && mkdir -p "$TARGET_DIR/handoff"
  copy_if_missing "$PACK_DIR/handoff/TEMPLATE.md"  "$TARGET_DIR/handoff/TEMPLATE.md"  && printf '    handoff/TEMPLATE.md\n' || true
  copy_if_missing "$PACK_DIR/handoff/_TEMPLATE.md" "$TARGET_DIR/handoff/_TEMPLATE.md" && printf '    handoff/_TEMPLATE.md\n' || true
}

# ── post-install hints ─────────────────────────────────────────────────

post_install_hints() {
  printf '\n%s════════════ 后续步骤 ════════════%s\n' "$BOLD" "$RESET"
  case "$TARGET_TYPE" in
    opencode)
      printf '  1. 编辑 %s/opencode.json\n' "$TARGET_DIR"
      printf '     替换 {env:VAR} 占位符和 MCP 路径\n'
      ;;
    codex)
      printf '  1. 编辑 %s/config.toml\n' "$TARGET_DIR"
      printf '     填入 token 与 provider 配置\n'
      ;;
    cursor)
      printf '  1. 查看 %s/.cursorrules\n' "$TARGET_DIR"
      printf '  2. 重启 Cursor 生效\n'
      printf '\n  核心规则已通过符号链接引用。更新仓库即可自动同步。\n'
      ;;
    claude)
      printf '  1. 查看 %s/CLAUDE.md\n' "$TARGET_DIR"
      printf '  2. 重启 Claude Code 生效\n'
      printf '\n  核心规则已通过符号链接引用。更新仓库即可自动同步。\n'
      ;;
    copilot)
      printf '  1. 查看 %s/.github/copilot-instructions.md\n' "$TARGET_DIR"
      printf '  2. 提交到 Git 仓库生效\n'
      printf '\n  核心规则已通过符号链接引用。更新仓库即可自动同步。\n'
      ;;
  esac
  [[ "$INIT_STATE" != "true" ]] && printf '\n  如需初始化状态文件，添加 --init-state 重新运行\n'
}

post_update_hints() {
  printf '\n%s════════════ 完成 ════════════%s\n' "$BOLD" "$RESET"
  printf '  检查更新后的 AGENTS.md 和规则文件。\n'
  printf '  live 状态文件已被保留。\n'
}

# ── main ───────────────────────────────────────────────────────────────

if [[ "$DRY_RUN" == "true" ]]; then
  [[ "$MODE" == "update" ]] && update_dry_run || install_dry_run
  exit 0
fi

echo -e "\n${BOLD}${CYAN}═══ Portable AI Runtime${RESET}\n"

if [[ "$MODE" == "update" ]]; then
  if [[ ! -d "$TARGET_DIR" ]]; then
    printf '目标目录不存在，执行全新安装\n'
    install_all
  else
    printf '  工具: %s | 目标: %s\n\n' "$TARGET_TYPE" "$TARGET_DIR"
    update_all
    printf '\n更新完成。'
    post_update_hints
    exit 0
  fi
else
  printf '  工具: %s | 目标: %s\n\n' "$TARGET_TYPE" "$TARGET_DIR"
  install_all
fi

if [[ "$INIT_STATE" == "true" ]]; then
  init_state_files
fi

printf '\n安装完成。'
post_install_hints
