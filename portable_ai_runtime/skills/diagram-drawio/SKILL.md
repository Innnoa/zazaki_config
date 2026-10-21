---
name: diagram-drawio
description: >
  Use when the user asks to draw structured diagrams — flowcharts,
  architecture diagrams, sequence diagrams, ER diagrams, mind maps,
  network topology, Gantt charts, etc. Triggers on "画流程图/架构图/时序图/ER图/思维导图/拓扑图/drawio/diagram/帮我画个图".
  Workflow: parse requirements -> write .drawio XML -> render PNG via
  Windows draw.io CLI -> review with deepseek-vision -> iterate (default
  max 2 rounds) -> deliver source + PNG.
---

# Diagram Drawio — 结构化图表生成

用自然语言需求生成可编辑的结构化图表,交付 `.drawio` 源文件 + 渲染 PNG,并通过视觉模型自动审查迭代。

## 角色边界

| 任务方向 | 用什么 | 示例 |
|---|---|---|
| **结构化图表**（流程图/架构图/时序图/ER 图/思维导图/拓扑等） | 本 skill（drawio XML） | 画系统架构图、登录流程图 |
| **像素级生图**（插画/概念图/照片风） | `gptimage2-prompting` → `fastaicode-image` | 画一张赛博朋克插画 |
| **已有图理解/审查** | `vision-analyze` → `deepseek-vision` | 分析截图、审查 UI |

本 skill 只负责结构化图表：矢量、可编辑、可版本控制。像素生图是另一条线，用户要"示意图/插画/海报"时转 gptimage2。

## 前置依赖

- **drawio CLI**：Windows 版 draw.io（用户级安装），WSL 可直接调用（已验证 v31.3.2）
- **渲染脚本**：`scripts/render.sh`（自动探测 drawio 路径并导出 PNG）
- **审查模型**：`deepseek-vision` agent（`vision-analyze` skill 的模型入口）
- **语法速查**：`references/drawio-syntax.md`（XML 骨架/节点/连线/样式/泳道/时序/ER/坑）

## 六步闭环

### Step 1: 解析需求

明确：图类型、关键节点/参与者、关系/流向、层级分组、方向（上下/左右）、配色偏好、目标输出格式（PNG/SVG/PDF，默认 PNG）。需求不明确时先补一句确认，不猜关键结构。

### Step 2: 生成 XML

- 先读 `references/drawio-syntax.md` 确认元素语法（尤其不熟悉的图类型）
- 直接写 `.drawio` 文件（UTF-8，`html=1` 保证中文正常）
- 结构要求：骨架完整（保留 `id="0"/"1"`）、所有 id 全局唯一、edge 必须 `relative="1"` 且两端连到节点、容器子节点用相对坐标
- 图类型不设限：流程图/架构图/时序图/ER 图/思维导图/拓扑图/甘特图等按需求选元素，语法速查未覆盖的类型基于 mxGraphModel 通用规则推导

### Step 3: 渲染

```bash
scripts/render.sh <file.drawio> [<out.png>]
```

- 渲染失败时：检查 XML 合法性（id 重复/缺 geometry/缺 relative），修复后重试；drawio 路径探测失败则提示用户确认 Windows 安装

### Step 4: 审查（vision 反馈）

- 调 `deepseek-vision` agent（或 `opencode run -m deepseek/deepseek-v4-flash-vision-exp`）审查 PNG
- 审查点：布局是否重叠/错位、连线是否合理清晰、节点文字是否完整可读、层级/分组是否符合需求、配色与样式一致性、整体可读性
- 图片 >300KB 先压缩（`ffmpeg -i <in> -vf scale=256:-1 -q:v 5 <out.jpg>`）
- 审查输入给足上下文：图类型、需求要点、期望输出格式（问题清单 + 位置 + 建议）

### Step 5: 迭代

- 根据审查意见修改 XML → 重渲染 → 再审
- 默认最多 2 轮自动迭代；用户喊停、指定轮数、或审查无实质问题时提前停止
- 每轮迭代只改审查指出的问题，不做无关重构

### Step 6: 交付

交付内容：
1. `.drawio` 源文件路径（可继续编辑）
2. 渲染 PNG（或其他指定格式）路径
3. 结构说明：图类型、主要节点/区域、关键设计点、已知局限（如需）

## 质量规则

- 不声称"画好了"而不交付文件路径；不虚构渲染结果
- 渲染必须实际执行并确认输出文件存在
- XML 合法性优先：宁可结构简单，不要残缺复杂
- 中文场景必须 `html=1` + UTF-8
- 迭代收敛即停，不空转

## 常见坑（详见语法速查 §9）

- `as="geometry"` 漏写 / edge 缺 `relative="1"` → 元素不显示
- 中文乱码 → 缺 `html=1`
- id 重复 / 悬空连线 → 结构破坏
- 容器子节点用绝对坐标 → 位置错乱

## 检验句

问自己：这是结构化图表任务吗（是 → 本 skill）？需求里的图类型和关键节点确认了吗？XML 语法（骨架/geometry/edge/相对坐标）对吗？渲染真的执行并出文件了吗？vision 审查过、迭代轮数到了吗？交付时给了源文件和 PNG 路径吗？
