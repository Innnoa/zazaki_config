---
name: ux-design
description: >
  This skill should be used when the user asks to design or review UI/UX — whether in English
  ("design UI", "design UX", "design an interface", "design a page", "review this design",
  "improve usability", "improve UX", "redesign", "make this more usable", "check this interface",
  "evaluate this design", "UI review", "UX review", "usability review") or in Chinese
  ("设计界面", "设计UI", "设计UX", "审查这个设计", "提升可用性", "优化用户体验",
  "重新设计", "检查这个界面", "评估这个设计").
  Also activate when designing or reviewing specific interface elements: "表单/表单设计",
  "导航/导航栏/菜单", "按钮/按钮设计", "布局/页面布局", "排版/文字排版", "配色",
  "组件/组件设计", "仪表盘/dashboard", "落地页/首页", "注册页", "定价页".
  Activate when the user mentions any UX law by name (Hick's Law, Fitts's Law, Miller's Law,
  Jakob's Law, Tesler's Law, Postel's Law, Pareto Principle, etc.) or asks about
  "UX法则", "UX原则", "交互原则", "设计法则", "可用性法则".
  Activate when building or reviewing frontend components, pages, forms, navigation, dashboards,
  or any user-facing interface where usability matters.
---

# UX Design

基于 30 条 UX 法则的结构化设计审查与指导。按功能分五层，按需路由。

## Always Read

- `rules/decision-efficiency.md`：决策效率层（Hick、Fitts、Doherty 等 7 条）
- `rules/cognition-memory.md`：认知记忆层（Miller、Cognitive Load、Chunking 等 8 条）

## Session Discipline

每个新任务——即使是同一会话的第 N 轮——必须重读本文件、重新匹配 Common Tasks 路由、重读该路由列出的必读文件。

**Session Discipline Gate**：

- [ ] 本次任务是否已重读本 SKILL.md？
- [ ] 是否已重新匹配 Common Tasks 路由？
- [ ] 是否已重读该路由列出的全部必读文件？

**任意一项未通过 → STOP。不得开始审查/设计工作。先执行缺失的读取步骤。**

检验：问自己"这次任务我读的文件和 Common Tasks 里对应路由列的完全一致吗？"如果有任何差异，立即回头重走路由。

## Core Principles

| 层级 | 关注点 | 文件 |
| --- | --- | --- |
| 决策效率 | 速度、选项、复杂度 | `rules/decision-efficiency.md` |
| 认知记忆 | 容量、负荷、注意 | `rules/cognition-memory.md` |
| 感知分组 | 视觉、分组、突出 | `rules/perception-grouping.md` |
| 期望模型 | 习惯、转移、宽容 | `rules/expectation-mental-model.md` |
| 动机体验 | 情绪、动力、沉浸 | `rules/motivation-experience.md` |

## Common Tasks

| 任务 | 必读文件 | 工作流 |
| --- | --- | --- |
| 设计/审查 导航、菜单、按钮、操作流 | `rules/decision-efficiency.md` + `rules/motivation-experience.md` | 逐条对照检查清单 |
| 设计/审查 表单、搜索、信息输入 | `rules/decision-efficiency.md` + `rules/cognition-memory.md` + `rules/expectation-mental-model.md` | 逐条对照检查清单 |
| 设计/审查 信息架构、内容排版 | `rules/cognition-memory.md` + `rules/perception-grouping.md` | 逐条对照检查清单 |
| 设计/审查 数据可视化、仪表盘 | `rules/perception-grouping.md` + `rules/cognition-memory.md` | 逐条对照检查清单 |
| 设计/审查 流程、引导、任务完成 | `rules/motivation-experience.md` + `rules/cognition-memory.md` | 逐条对照检查清单 |
| 设计/审查 视觉风格、品牌一致性 | `rules/perception-grouping.md` + `rules/expectation-mental-model.md` | 逐条对照检查清单 |
| 通用 UI 审查 / 未分类 | 全部五层 | 先逐层扫描，再定位问题层深入 |
| 多子任务 | 派发给独立 agent 分别审查不同页面/模块 | `references/gotchas.md` 共享 |

## 视觉设计系统

**默认配色：Catppuccin Mocha。** 所有颜色变量使用 `--ctp-mocha-*` 前缀或等价映射，详细色板见 `references/catppuccin-mocha.md`。

**可选视觉方案：`apple-design` skill。** 当用户明确要求极简/现代/Apple 风格时，加载 `skills/apple-design/SKILL.md`。该 skill 提供完整的视觉实现层（颜色、字体、8px 网格、玻璃态、动画），配色已替换为 Catppuccin Mocha。

ux-design 管"交互对不对"，apple-design 管"看起来怎么样"。两者可同时激活，分工不重叠。

## Known Gotchas

- 常见跨法则冲突：`references/gotchas.md`
- 配色设计默认使用 Catppuccin Mocha 主题，不得混用其他色板命名体系：`references/catppuccin-mocha.md`
- 视觉系统选择冲突：如同时加载了 `apple-design` 和其他视觉系统 skill，以 Catppuccin Mocha + apple-design 为准，忽略其他配色方案
- 每个规则文件末尾自带检查清单，审查时逐条对照
- "优化其中一个法则而破坏另一个"是最高频错误——每改一处，至少检查一次相关法则是否受影响

## 使用方式

1. 确定任务属于哪（几）个层级
2. 读取对应层级的规则文件
3. 用每条法则的"检验"句逐条审查设计
4. 输出问题清单 + 修改建议
5. 如有跨法则冲突，查阅 `references/gotchas.md`
