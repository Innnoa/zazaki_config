---
name: gptimage2-prompting
description: >
  Use when the user asks to generate text-to-image prompts, write image generation instructions, create AI image prompts, or needs prompt examples for GPT-Image-2 / DALL-E / Midjourney / Stable Diffusion.
  Also activate when the user mentions 文生图, 提示词, 生图, image prompt, 生成图片, prompt engineering for images, or asks about specific visual styles (写实摄影, 动漫, 概念艺术, UI设计, 扁平插画, 儿童绘本, Logo设计, 产品摄影, 像素艺术, 等距插画, 体素, voxel, pixel art, isometric).
---

# GPT-Image-2 文生图提示词

## Overview

提供 GPT-Image-2 五类核心风格的实战 prompt 库，每条含效果说明、参数建议、适用场景和常见避坑。覆盖写实摄影、动漫、概念艺术、UI/产品、插画及新增的像素艺术、等距插画、体素/3D 风格。

## When to Use

- 用户需要生成某个风格/场景的文生图 prompt
- 用户对某类效果不满意，需要调优策略
- 用户想了解 GPT-Image-2 在某类场景下的能力和局限
- 用户需要参考 prompt 框架和参数速查

## Always Read

- 理解 prompt 框架和通用技巧：先读 `references/catalog.md` 头部
- 具体风格 prompt：按需读取对应分类文件

## Quick Reference

| 风格分类 | 场景 | 位置 |
|----------|------|------|
| 写实/摄影 | 人像、风景、产品摄影 | `references/prompts/realistic/` |
| 动漫 | 角色设计、场景插画 | `references/prompts/anime/` |
| 概念艺术 | 奇幻、科幻 | `references/prompts/concept-art/` |
| UI/产品 | 界面设计、Logo、产品模型 | `references/prompts/ui-product/` |
| 插画 | 扁平风格、儿童绘本 | `references/prompts/illustration/` |
| 像素艺术 | 角色、场景、游戏素材 | `references/prompts/pixel-art/` |
| 等距插画 | 房间、城市、游戏场景 | `references/prompts/isometric/` |
| 体素/3D | 场景、角色、景观 | `references/prompts/voxel-3d/` |

## Core Principles

1. **五要素框架**：任务类型 → 主体描述 → 风格定义 → 技术参数 → 输出规格
2. **具体 > 模糊**：描述越具体，输出越精准
3. **中文直接说**：不需要翻译成英文（关键词保留英文）
4. **给文字，不要描述文字**：直接把要出现在图中的文案写在 prompt 里
5. **`photorealistic` 是万能钥匙**：单用一个词就能大幅提升真实感
6. **标注比例和分辨率**：`3:4, 4K` 即可控制输出尺寸

## Common Tasks

| 任务 | 操作 |
|------|------|
| 用户指定风格生成 prompt | 按 Quick Reference 定位分类文件，选取或改编对应 prompt |
| 效果不理想需要调优 | 查对应风格的「常见避坑」段落和 README「迭代优化指引」 |
| 用户提供新场景无现成 prompt | 用五要素框架从零构建，参考同风格文件的参数建议 |
| 用户问某个风格的局限 | 引用对应文件的「已知局限性」和末尾「常见避坑」 |

## Known Gotchas

- 亚洲人脸一致性不如欧美面孔，重要角色建议多轮迭代或垫图
- 严密 3D 逻辑任务（折纸、魔方）容易翻车
- 白底图必须上传产品垫图，否则模型会"创作"产品
- UI 截图加一句 `不要生成手机外壳，只输出纯界面截图`
- 体素风格容易被渲染成低模 3D，需强调"可见单个体素立方体"

## Prompt 文件索引

完整的 prompt 库位于 `~/Projects/gptimage2-prompts/`，包含：
- `README.md` — 框架说明、参数速查、迭代优化指引
- 8 个风格子目录 × 2-3 个场景文件 = 21+ 条实战 prompt
- `outputs/` — 实测成品图参考

每个 prompt 文件包含：原文 → 效果说明 → 参数建议表 → 适用场景 → 通用技巧 → 常见避坑。
