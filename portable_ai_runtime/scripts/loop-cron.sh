#!/usr/bin/env bash
# loop-cron.sh — cron 心跳入口，安全触发 goal-runner.py
#
# 用法：
#   loop-cron.sh <tasks-dir>
#
# crontab 示例：
#   0 9 * * 1-5  ~/.config/opencode/scripts/loop-cron.sh ~/Projects/tasks
#
# 特性：
#   - flock 互斥锁：防止同一 tasks 目录并发执行
#   - 退出前自动释放锁
#   - goal-runner.py 本身支持断点恢复，异常中断后下次执行自动继续

set -euo pipefail

TASKS_DIR="${1:-$HOME/Projects/tasks}"
if [ ! -d "$TASKS_DIR" ]; then
    echo "loop-cron.sh: tasks directory not found: $TASKS_DIR" >&2
    echo "Create it first, or use /task 'description' in OpenCode to add tasks." >&2
    exit 1
fi

LOCKFILE="/tmp/goal-run-tasks-$(echo "$TASKS_DIR" | tr '/' '_').lock"

exec {LOCK_FD}>"$LOCKFILE"

if ! flock -n "$LOCK_FD"; then
    echo "loop-cron.sh: goal-runner already running for $TASKS_DIR, skipping." >&2
    exit 0
fi

trap 'flock -u "$LOCK_FD"; rm -f "$LOCKFILE"' EXIT

GOAL_RUNNER="$HOME/.config/opencode/scripts/goal-runner.py"

if [ ! -f "$GOAL_RUNNER" ]; then
    echo "loop-cron.sh: goal-runner.py not found at $GOAL_RUNNER" >&2
    exit 1
fi

echo "[$(date -Iseconds)] loop-cron.sh: starting goal-runner for tasks in $TASKS_DIR"

TOPIC="zazaki-daily-22277d10"

# 统计 tasks 目录下 _pending / _done / _failed 文件夹数量
count_states() {
    local pending=0 done=0 failed=0
    local d
    for d in "$TASKS_DIR"/*; do
        [ -d "$d" ] || continue
        case "$(basename "$d")" in
            *_pending)          pending=$((pending + 1)) ;;
            *_done|*_done_*)    done=$((done + 1)) ;;
            *_failed|*_failed_*) failed=$((failed + 1)) ;;
        esac
    done
    echo "$pending $done $failed"
}

read -r PENDING_BEFORE DONE_BEFORE FAILED_BEFORE <<<"$(count_states)"

# 捕获 goal-runner 输出并显式处理退出码（set -e 下命令替换失败会直接退出）
set +e
GOAL_OUTPUT="$(python3 "$GOAL_RUNNER" --tasks-dir "$TASKS_DIR" 2>&1)"
GOAL_RC=$?
set -e

# 保留原有日志行为：输出照旧进 cron 日志
printf '%s\n' "$GOAL_OUTPUT"

read -r _PENDING_AFTER DONE_AFTER FAILED_AFTER <<<"$(count_states)"
DONE_DELTA=$((DONE_AFTER - DONE_BEFORE))
FAILED_DELTA=$((FAILED_AFTER - FAILED_BEFORE))
TOTAL_DELTA=$((DONE_DELTA + FAILED_DELTA))

echo "[$(date -Iseconds)] loop-cron.sh: goal-runner finished for $TASKS_DIR (rc=$GOAL_RC, +$DONE_DELTA done, +$FAILED_DELTA failed)"

# 空跑: 无待办任务时 goal-runner 以 1 退出（提示用 /goal 或 /task），属正常；
# 不推送，也不以非零传播为 cron 失败
if [[ $TOTAL_DELTA -eq 0 && $GOAL_RC -ne 0 && $PENDING_BEFORE -eq 0 ]]; then
    echo "[$(date -Iseconds)] loop-cron.sh: 无待办任务（goal-runner rc=1 属正常空跑），跳过推送。"
    exit 0
fi

# 本轮没有实际完成/失败的任务
if [[ $TOTAL_DELTA -eq 0 ]]; then
    if [[ $GOAL_RC -ne 0 ]]; then
        echo "[$(date -Iseconds)] loop-cron.sh: goal-runner 非零退出 (rc=$GOAL_RC) 且无任务状态变化，作为 cron 失败传播。" >&2
        exit "$GOAL_RC"
    fi
    echo "[$(date -Iseconds)] loop-cron.sh: goal-runner 本轮无任务完成，不推送。"
    exit 0
fi

# 有实际工作 → 推送摘要（curl --data-binary @-，禁止 -d：会 url-encode 吞掉换行）
BODY="goal-runner 完成 $TOTAL_DELTA 个任务（$DONE_DELTA 完成, $FAILED_DELTA 失败）"
NAMES="$(printf '%s\n' "$GOAL_OUTPUT" |
    sed -n -e 's/^[[:space:]]*✓ \([^ ]*_done[0-9_]*\)[[:space:]]*$/\1/p' \
           -e 's/.*任务已标记为 _failed: \([^ ]*\)$/\1/p' |
    sed -e 's/_done[0-9_]*$//' -e 's/_pending$//' |
    head -6)"
if [[ -n "$NAMES" ]]; then
    while IFS= read -r name; do
        BODY+=$'\n- '"$name"
    done <<< "$NAMES"
fi

if curl -sfS -H "Title: Goal Runner" --data-binary @- "https://ntfy.sh/$TOPIC" <<< "$BODY" >/dev/null 2>&1; then
    echo "[$(date -Iseconds)] loop-cron.sh: 已推送 goal-runner 摘要 ($TOTAL_DELTA 个任务)。"
else
    echo "[$(date -Iseconds)] loop-cron.sh: 推送失败 (curl 非零)。" >&2
fi
exit 0
