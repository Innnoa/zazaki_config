---
description: 停止当前项目的 goal-run 后台进程
agent: build
---

用户想停止当前项目中正在运行的 goal-run 后台进程。

## 执行步骤

1. 从项目根目录读取 PID 文件：
   ```bash
   cat .goal-run.pid 2>/dev/null | head -1
   ```

2. 如果 PID 存在且进程存活，执行停止：
   ```bash
   kill <PID> 2>/dev/null && echo "STOPPED" || echo "FAILED"
   ```

3. 如果 kill 失败（进程可能已死），用 `kill -9 <PID>` 强制终止。

4. 确认停止后：
   - 进程终止 → goal-run 的 SIGTERM 处理器会自动将状态设为 `paused`
   - 清理 `.goal-run.pid` 文件（可选 — 保留可用于排查）
   - 告知用户：
     - 进程已停止
     - 状态已保存（可 `/goal-start` 恢复继续）
     - 已完成的工作不会丢失

5. 如果本来就没有进程在运行，告诉用户："当前没有 goal-run 在运行。"

6. 停止后建议用户运行 `/goal-outcome` 查看已完成的工作。
