---
description: 在后台启动 goal-runner 处理 ~/Projects/tasks/ 中的待办任务
agent: build
---

用户希望在当前项目中后台启动 goal-runner 循环，执行 `~/Projects/tasks/` 中的待办任务。

## 执行步骤

1. 检查 `~/Projects/tasks/` 下是否有待办：
   ```bash
   ls -d ~/Projects/tasks/*_pending/ 2>/dev/null
   ```
   若没有，提示用户用 `/task "描述"` 创建。

2. 启动 goal-runner：
   ```bash
   python3 ~/.config/opencode/scripts/goal-runner.py --tasks-dir ~/Projects/tasks
   ```

3. goal-runner.py 启动后自动：
   - 扫描 `~/Projects/tasks/` 下的 `*_pending/`
   - 从每个 TASK.md 读取工作目录
   - 在该工作目录下执行 P→A→T→V→R 循环
   - 完成后将 `_pending` 重命名为 `_done`，写入 COMPLETION.md

4. 定时运行（可选）：
   编辑 `crontab -e`，添加：
   ```
   0 9 * * 1-5  ~/.config/opencode/scripts/loop-cron.sh ~/Projects/tasks
   ```
