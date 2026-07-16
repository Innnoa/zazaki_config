---
description: 在后台启动 goal-run 自主执行 — 无需退出 OpenCode
agent: build
---

用户希望在当前项目中后台启动 goal-run 编排器。你需要检查状态、启动进程、告知用户。

## 执行步骤

1. 先找到项目根目录 — 从当前目录向上查找 `GOAL_STATE.json`。
   如果找不到，告诉用户先用 `/goal <描述>` 创建目标。

2. 检查该项目是否已有 goal-run 在运行（通过项目专属 PID 文件）：
   ```bash
   cat .goal-run.pid 2>/dev/null && ps -p $(cat .goal-run.pid) > /dev/null 2>&1 && echo "ALIVE" || echo "DEAD_OR_ABSENT"
   ```
   如果 ALIVE，报告 PID 和状态，不要重复启动。

3. 同时检查是否有同名项目的旧日志，读取最后几行看上次是否异常退出。

4. 后台启动 goal-run（**必须显式传入 --project-dir**）：
   ```bash
   LOGFILE="/tmp/goal-run-$(echo $PWD | md5sum | cut -c1-8).log"
   nohup goal-run --project-dir "$(pwd)" > "$LOGFILE" 2>&1 &
   GOAL_PID=$!
   echo $GOAL_PID > .goal-run.pid
   echo "LOGFILE=$LOGFILE" >> .goal-run.pid
   echo $GOAL_PID
   ```

5. 启动后向用户汇报：
   - PID: `<PID>`
   - 日志: `<LOGFILE>`（可供 `tail -f` 实时查看）
   - 进度: 可用 `/goal-status` 查看
   - 成果: 完成后用 `/goal-outcome` 查看
   - 停止: `kill <PID>`

6. 等待 5 秒后验证存活：
   ```bash
   sleep 5 && ps -p <PID> > /dev/null 2>&1 && echo "ALIVE" || echo "DEAD"
   ```
   如果 DEAD，读取日志最后 20 行，排查错误原因并告知用户。

## 注意事项

- PID 文件和 GOAL_STATE.json 在同一目录（项目根）
- 不同项目的日志通过项目路径 hash 隔离，不会互相覆盖
- 如果旧 PID 文件存在但进程已死，视为未运行，直接覆盖启动
