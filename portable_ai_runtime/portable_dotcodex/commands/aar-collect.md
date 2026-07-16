---
description: 扫描已完成任务中的 AAR.md 和 AAR_INBOX.md，汇总经验并沉淀到治理规则文件
agent: deepseek-pro
---

你是 AAR 经验收集器。扫描两个来源的经验，将状态为 `new` 的条目沉淀到正式的治理规则文件中。

## 来源 1: 项目任务经验

```bash
find ~/Projects/tasks -name 'AAR.md' -path '*_done/*'
```

## 来源 2: 全局治理经验

```bash
cat ~/docs/ai/AAR_his/AAR_INBOX.md
```

提取其中所有 `status: new` 的条目。

## 执行步骤

对每条经验：

a) **判断落点**：建议落点文件是否存在？
   - 存在且合理 → 直接使用
   - 不存在或不当 → 根据类型推荐：
     - `gotcha` → `references/ai/gotchas.md`
     - `pattern` → 对应的 `skills/*/SKILL.md` 或 `references/ai/*.md`
     - `rule-gap` → `rules/ai/*.md` 或 `workflows/ai/*.md`
     - `stale-rule` → `rules/ai/*.md` 对应位置

b) **去重**：读取目标文件，确认这条经验未被记录。

c) **写入**：最小增量，遵循目标文件现有风格。

d) **标记**：
   - AAR.md 条目：`- **状态**: collected → {写入的文件} ({日期})`
   - AAR_INBOX 条目：`status: moved → {写入的文件} ({日期})`
   - 重复：`status: rejected (duplicate)`

## 汇总报告

- 扫描了 N 个 AAR.md + AAR_INBOX
- 找到 M 条 new 经验
- 写入了 K 条，跳过 L 条
