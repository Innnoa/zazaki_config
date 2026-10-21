---
name: vision-analyze
description: >
  Use when the user needs image understanding or visual analysis — describing
  images/screenshots, reading text from images (OCR plus semantics), reviewing
  UI screenshots against design rules, diagnosing a visual defect from a
  screenshot, or combining an image with a code task (design-to-code, layout
  review). Triggers on "看图/识图/描述这张图/分析截图/视觉审查/图像理解" and on
  any task that includes an image attachment. Complements gptimage2-prompting
  (generation) and playwright screenshots (capture); this skill is the
  understanding side. Powered by the `deepseek-v4-flash-vision-exp` model
  (agent entry: `deepseek-vision`).
---

# Vision Analyze — 图像理解与视觉分析

## 角色边界

视觉任务三向分流，先判定方向再动手：

| 任务方向 | 用什么 | 示例 |
|---|---|---|
| **理解/分析**（已有图像） | 本 skill → `deepseek-vision` | 描述图片、OCR、截图审查、视觉缺陷诊断 |
| **生成/编辑**（无图需造图） | `gptimage2-prompting` skill → `fastaicode-image` MCP | 生成插画、改图 |
| **采集**（需先抓屏/抓页面） | Playwright MCP 截图 → 再走本 skill | 网页渲染验证、UI 截图审查 |

本 skill 只负责"已有图像的输入侧理解"，不负责造图（那是 gptimage2 的职责）。

## 模型与调用

- 模型：`deepseek/deepseek-v4-flash-vision-exp`
- Agent 入口：`deepseek-vision`（opencode.json 已配置）
- 走 k8s 内网网关（HTTP，OpenCode 侧已配好，无需额外处理）
- 推理模型：回答前有 thinking 过程，复杂视觉任务可用但比纯 flash 慢（典型 3-5s）

## 工作流

1. **判定方向**：按上表确认是"理解"方向，是则继续；生成/采集方向转到对应技能。
2. **准备图像**：
   - 本地图片：确认路径存在；若大于 ~300KB，先压缩（`ffmpeg -i <in> -vf scale=256:-1 -q:v 5 <out.jpg>` 或等效），避免 payload 超限
   - 网页/界面：先用 Playwright MCP 截屏保存到本地，再走图像理解
   - 网络图片：下载到本地后处理
3. **构造多模态请求**：图像 + 明确任务文字（描述/审查/诊断/转码）。给任务文字时说明上下文与期望输出格式。
4. **执行**：通过 `deepseek-vision` agent 或 `opencode run -m deepseek/deepseek-v4-flash-vision-exp` 调用；或直接在会话内把图片附件 + 问题发给该模型。
5. **结果落地**：视觉审查类给出结构化结论（问题清单 + 证据位置 + 修复建议）；描述类直接给准确描述；诊断类给出根因判断。

## 典型场景

### 1. 截图审查（UI/UX 视觉审查）

配合 `ux-design` skill：先用 Playwright 截屏，再让 vision 模型按 ux-design 五层法则检查截图（布局、层级、间距、配色、可访问性），产出问题清单。vision 给出"看到了什么"，ux-design 给出"应该怎样"，两者结合 = 视觉审查闭环。

### 2. 设计稿转代码（design-to-code）

把设计稿截图 + 需求文字给 vision 模型 → 得到结构化的布局描述（区块、颜色、间距、组件类型）→ 交给 @designer/@fixer 按描述实现。vision 负责"看懂设计"，designer 负责"实现设计"。

### 3. 视觉缺陷诊断

截图 + 错误描述 → vision 定位视觉问题（元素重叠、颜色错误、响应式断裂、资源缺失）→ 给出修复方向。

### 4. 图像描述 / OCR 增强

- 描述：给准确、客观的图像内容描述（人物/场景/界面/图表）
- OCR：提取图片文字 + 语义理解（比纯 OCR 多一层上下文解释）

## 与现有能力的协作

- **生成**：`gptimage2-prompting`（prompt 工程）→ `img` command / `fastaicode-image` MCP（执行）
- **采集**：Playwright MCP `browser_take_screenshot`
- **审查**：`ux-design` skill（法则）+ 本 skill（视觉证据）
- **前端实现**：@designer（视觉）/@fixer（机械）

## 注意事项

- 大图必须压缩（>300KB 会超 payload 限制，实测 400KB 原图失败）
- 图像输入用 `data:image/jpeg;base64,...` 或本地文件路径均可（OpenCode 会处理附件）
- 视觉模型是推理型：复杂任务先想后答，给足上下文效果更好
- 不要用它做纯文本任务（那是 flash/pro 的职责，vision 无优势还更慢）

## 检验句

问自己：任务是"理解已有图像"还是"生成新图像"？理解 → 本 skill + deepseek-vision；生成 → gptimage2；采集 → Playwright。图像是否已压缩到可用大小？
