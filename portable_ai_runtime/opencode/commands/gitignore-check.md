---
description: 检查并应用 AI 产物排除规则到项目 .gitignore 和 pre-commit hook
---

运行 `bash ~/.config/opencode/scripts/gitignore-check.sh`。
该脚本读取模板 `templates/gitignore/ai-artifacts.gitignore` 作为权威模式源，
检查项目 `.gitignore` 是否包含所有条目，追加缺失条目并标注来源；
检查 `.git/hooks/pre-commit` 是否存在且指向正确的 hook 版本，缺失或过旧时自动安装/更新。
