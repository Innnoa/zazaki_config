---
description: 查看后台 goal-run 的实时运行状态
agent: build
---

用户想查看当前项目中 goal-run 后台进程的运行状态。

## 执行步骤

1. 查找项目根目录（向上找 GOAL_STATE.json）。

2. 检查进程存活（通过项目专属 PID 文件）：
   ```bash
   PID=$(cat .goal-run.pid 2>/dev/null | head -1)
   if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
     echo "RUNNING $PID"
   else
     echo "NOT_RUNNING"
   fi
   ```

3. 读取 `GOAL_STATE.json` 获取状态：
   - `status` / `phase` / `iteration`
   - `budget_used` / `budget_total`
   - `current_plan` 中 ✓ 和非 ✓ 项
   - `history` 最后 5 条

4. 如果有日志文件，读取最后 20 行显示最近动态：
   ```bash
   LOGFILE=$(grep LOGFILE .goal-run.pid 2>/dev/null | cut -d= -f2)
   tail -20 "$LOGFILE" 2>/dev/null
   ```

5. 按以下格式输出：

```
## goal-run 运行状态

**进程**: <RUNNING (PID: XXXX) / 未运行>

**目标**: <goal>
**状态**: <运行中/已完成/已暂停/预算耗尽>
**阶段**: <规划/执行/测试/审查>
**进度**: 第 X 轮 · 子任务 Y/Z · 预算用量 W%

**子任务**:
 ✅ task1
 ⏳ task2（进行中）
 ⬜ task3

**最近动态**:
- [ACT] 已完成: ...
- [TEST] 测试通过

**操作提示**:
- 停止: kill <PID>
- 实时: tail -f <LOGFILE>
- 成果: /goal-outcome
```

如果进程未运行但 GOAL_STATE.json 存在，显示静态状态，并提示：
- 状态为 completed → 运行 `/goal-outcome` 查看成果
- 状态为 paused → 运行 `/goal-start` 恢复
- 状态为 ready → 运行 `/goal-start` 启动
