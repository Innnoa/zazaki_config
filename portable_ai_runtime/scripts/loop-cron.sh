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
python3 "$GOAL_RUNNER" --tasks-dir "$TASKS_DIR"
echo "[$(date -Iseconds)] loop-cron.sh: goal-runner finished for $TASKS_DIR"
