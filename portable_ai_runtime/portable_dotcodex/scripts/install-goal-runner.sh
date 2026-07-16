#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
WRAPPER="${BIN_DIR}/goal-run"
RUNNER="${HOME}/.config/opencode/scripts/goal-runner.py"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}== Goal Runner Installer ==${NC}"
echo ""

# 1. Ensure runner script exists
if [[ ! -f "${RUNNER}" ]]; then
    echo -e "${RED}✗${NC} Runner script not found: ${RUNNER}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Runner script: ${RUNNER}"

# 2. Create ~/.local/bin
mkdir -p "${BIN_DIR}"

# 3. Write wrapper
cat > "${WRAPPER}" << 'ENDOFSCRIPT'
#!/usr/bin/env bash
# goal-run — autonomous goal runner wrapper for OpenCode
# Usage: goal-run [--project-dir <path>]

set -euo pipefail

RUNNER="${HOME}/.config/opencode/scripts/goal-runner.py"

find_project_dir() {
    local d="${PWD}"
    while [[ "${d}" != "/" ]]; do
        if [[ -f "${d}/GOAL_STATE.json" ]] || [[ -d "${d}/.git" ]]; then
            echo "${d}"
            return 0
        fi
        d="$(dirname "${d}")"
    done
    echo "${PWD}"
}

PROJECT_DIR=""
ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir|-d)
            PROJECT_DIR="$2"
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

if [[ -z "${PROJECT_DIR}" ]]; then
    PROJECT_DIR="$(find_project_dir)"
fi

cd "${PROJECT_DIR}"
exec python3 "${RUNNER}" "${ARGS[@]}"
ENDOFSCRIPT

chmod +x "${WRAPPER}"
echo -e "${GREEN}✓${NC} Wrapper installed: ${WRAPPER}"

# 4. Check PATH
if [[ ":${PATH}:" == *":${BIN_DIR}:"* ]]; then
    echo -e "${GREEN}✓${NC} ${BIN_DIR} is already in PATH"
else
    echo -e "${YELLOW}⚠${NC}  ${BIN_DIR} is NOT in PATH."
    echo ""
    echo "  Add this to your ~/.zshrc or ~/.bashrc:"
    echo ""
    echo -e "    ${GREEN}export PATH=\"\${HOME}/.local/bin:\${PATH}\"${NC}"
    echo ""
fi

echo ""
echo -e "${GREEN}Done!${NC}"
echo "  In OpenCode TUI:  /goal \"your goal description\""
echo "  In another terminal: goal-run"
