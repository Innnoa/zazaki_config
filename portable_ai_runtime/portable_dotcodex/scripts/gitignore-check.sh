#!/usr/bin/env bash
set -euo pipefail

OPENDIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$OPENDIR/templates/gitignore/ai-artifacts.gitignore"
HOOK_SRC="$OPENDIR/scripts/git-hooks/pre-commit"
SEPARATOR="# === AI 产物排除规则（来源: templates/gitignore/ai-artifacts.gitignore）==="

# Determine project root
if ! PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
    echo "错误: 当前目录不在 git 仓库中" >&2
    exit 1
fi

GITIGNORE="$PROJECT_ROOT/.gitignore"
HOOK_DST="$PROJECT_ROOT/.git/hooks/pre-commit"
CHANGED=false

# --------------------------------------------------
# 1. Check / apply .gitignore patterns
# --------------------------------------------------
extract_patterns() {
    # Extract non-comment, non-empty lines from the template
    grep -v '^\s*#' "$1" | grep -v '^\s*$' || true
}

if [[ -f "$TEMPLATE" ]]; then
    TEMPLATE_PATTERNS=$(extract_patterns "$TEMPLATE")
else
    echo "错误: 模板文件不存在: $TEMPLATE" >&2
    exit 1
fi

MISSING_PATTERNS=()
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    found=false
    if [[ -f "$GITIGNORE" ]]; then
        # Check for exact pattern match in gitignore
        if grep -qFx "$line" "$GITIGNORE"; then
            found=true
        fi
    fi
    if [[ "$found" == false ]]; then
        MISSING_PATTERNS+=("$line")
    fi
done <<< "$TEMPLATE_PATTERNS"

if [[ ${#MISSING_PATTERNS[@]} -gt 0 ]]; then
    echo "检测到 .gitignore 缺少以下 AI 产物条目:"
    for pat in "${MISSING_PATTERNS[@]}"; do
        echo "  + $pat"
    done

    # Append separator + missing entries
    {
        echo ""
        echo "$SEPARATOR"
        for pat in "${MISSING_PATTERNS[@]}"; do
            echo "$pat"
        done
    } >> "$GITIGNORE"

    echo "已追加到 $GITIGNORE"
    CHANGED=true
else
    echo ".gitignore: 已全覆盖，无需操作"
fi

# --------------------------------------------------
# 2. Check / install pre-commit hook
# --------------------------------------------------
if [[ -L "$HOOK_DST" ]]; then
    TARGET=$(readlink -f "$HOOK_DST")
    EXPECTED=$(readlink -f "$HOOK_SRC")
    if [[ "$TARGET" == "$EXPECTED" ]]; then
        echo "pre-commit hook: 已存在且指向正确，无需操作"
    else
        echo "pre-commit hook: 符号链接指向过期版本 ($TARGET)，正在更新..."
        rm -f "$HOOK_DST"
        ln -s "$HOOK_SRC" "$HOOK_DST"
        echo "pre-commit hook: 已更新"
        CHANGED=true
    fi
elif [[ -f "$HOOK_DST" ]]; then
    echo "pre-commit hook: 存在但非符号链接，正在替换..."
    rm -f "$HOOK_DST"
    ln -s "$HOOK_SRC" "$HOOK_DST"
    echo "pre-commit hook: 已替换为符号链接"
    CHANGED=true
else
    mkdir -p "$(dirname "$HOOK_DST")"
    ln -s "$HOOK_SRC" "$HOOK_DST"
    echo "pre-commit hook: 已安装"
    CHANGED=true
fi

# --------------------------------------------------
# 3. Summary
# --------------------------------------------------
if [[ "$CHANGED" == true ]]; then
    echo ""
    echo "完成: 已应用 AI 产物排除规则"
else
    echo ""
    echo "已全覆盖，无需操作"
fi
