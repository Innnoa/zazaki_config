---
description: 列出 ~/Projects/tasks/ 下的所有待办、已完成和失败任务
agent: build
---

列出 `~/Projects/tasks/` 目录下所有任务。

扫描并分类展示：

1. **待办** (`*_pending/`)：文件夹名、目标摘要、工作目录
2. **已完成** (`*_done/`)：文件夹名、目标摘要
3. **失败** (`*_failed/` 或 `*_failed_*/`)：文件夹名、失败原因（从 COMPLETION.md 或最后日志获取）

用三张表格分别展示。

如果目录不存在或为空，提示用户用 `/task "描述"` 创建。
