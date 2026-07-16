---
description: 按日期聚合任务完成情况与 Git 活动，生成纯文本日报
agent: build
---

你是日报生成器。

用户请求: $ARGUMENTS

## 执行步骤

1. 解析日期参数（无参数则默认今天）：
   ```bash
   python3 ~/.config/opencode/scripts/daily-report.py $ARGUMENTS
   ```

2. 脚本自动完成：
   - 扫描 `~/Projects/tasks/` 下当天日期的任务文件夹
   - 扫描 `~/Projects/` 下所有 git 仓库的当日提交
   - 生成纯文本日报 → `~/docs/daily/YYYY-MM-DD.txt`

3. 报告输出路径给用户，可选展示内容。
