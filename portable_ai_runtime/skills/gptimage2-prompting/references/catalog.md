# GPT-Image-2 提示词速查目录

> 完整 prompt 库位于 `~/Projects/gptimage2-prompts/`。
> 以下为分类摘要——每条 prompt 的完整版（含参数建议、效果说明、避坑）请按需读取对应文件。

## 提示词框架（五要素）

```
[任务类型] + [主体描述] + [风格定义] + [技术参数] + [输出规格]
```

### 参数速查

| 参数 | 含义 |
|------|------|
| `1:1` | 头像、社交主图 |
| `3:4` | 竖版海报、人像特写 |
| `9:16` | 手机壁纸、电商详情 |
| `16:9` | 横版海报、公众号封面 |
| `4K` | 高清输出 |
| `8K` | 超高清（Beta） |
| `photorealistic` | 写实模式，规避塑料感 |
| `cinematic lighting` | 电影级打光 |
| `octane 渲染` | 产品/概念艺术质感 |

---

## 分类索引

### 1. 写实/摄影 (`references/prompts/realistic/`)

| 场景 | 文件 | 核心锚点 |
|------|------|----------|
| 自然街头抓拍 | `portrait.md` | 35mm, Kodak Portra 400, 不要看镜头 |
| 棚拍时尚特写 | `portrait.md` | Rembrandt lighting, 杂志封面品质 |
| 环境情绪肖像 | `portrait.md` | 电影级打光, 冷暖对比, 雨夜 |
| 高山日出全景 | `landscape.md` | 广角16mm, National Geographic |
| 都市夜景航拍 | `landscape.md` | 长曝光, 车流光轨 |
| 极简自然意境 | `landscape.md` | Michael Kenna, 大面积留白 |
| 白底精修产品 | `product-photography.md` | RGB 255,255,255, 需上传垫图 |
| 场景化产品 | `product-photography.md` | 大理石台面, 侧逆光 |
| 电商详情页 | `product-photography.md` | 9:16, Thinking 模式 |
| 产品微距 | `product-photography.md` | 100mm f/2.8, 浅景深 |

### 2. 动漫 (`references/prompts/anime/`)

| 场景 | 文件 | 核心锚点 |
|------|------|----------|
| 角色立绘 | `character.md` | 新海诚 / 京都动画 / 吉卜力 |
| 十六宫格表情 | `character.md` | 高度一致, 逐列表情 |
| 战斗场景 | `character.md` | ufotable, 动态定格 |
| 吉卜力自然 | `scene.md` | 丁达尔光效, 空气透视 |
| 赛博朋克都市 | `scene.md` | 攻壳机动队, 霓虹+湿地面 |
| 治愈系日常 | `scene.md` | 新海诚, 蓝调时刻, 背影构图 |

### 3. 概念艺术 (`references/prompts/concept-art/`)

| 场景 | 文件 | 核心锚点 |
|------|------|----------|
| 史诗城邦 | `fantasy.md` | 尺度对比(小人影), octane 渲染 |
| 暗黑角色 | `fantasy.md` | 不对称设计, 底光 |
| 生物图鉴 | `fantasy.md` | 博物图鉴, 信息图布局 |
| 太空舰队 | `sci-fi.md` | 舷窗构图, 真空中爆炸球形 |
| 机甲设计 | `sci-fi.md` | 实用军事美学, 外露机械结构 |
| 赛博格 | `sci-fi.md` | 半人半机, 义体自发光 |

### 4. UI/产品 (`references/prompts/ui-product/`)

| 场景 | 文件 | 核心锚点 |
|------|------|----------|
| App 首页 | `ui-design.md` | CSS 级数值(px/hex), 不生成手机壳 |
| SaaS 仪表盘 | `ui-design.md` | 真实图表, Inter 字体 |
| Landing Page | `ui-design.md` | 极简, hex 精确配色 |
| 极简 Logo | `logo-design.md` | 设计理念, 纯黑单色 |
| 字母组合 Logo | `logo-design.md` | Lettermark, 双色渐变 |
| 徽章 Logo | `logo-design.md` | Emblem, EST.年份 |
| 包装盒样机 | `product-mockup.md` | 烫金, 品牌识别一体化 |
| 多角度展示 | `product-mockup.md` | 三视角, 地面倒影 |
| 饮料标签 | `product-mockup.md` | 边缘光, 场景化吧台 |

### 5. 插画 (`references/prompts/illustration/`)

| 场景 | 文件 | 核心锚点 |
|------|------|----------|
| 水彩动物故事 | `children-book.md` | 水彩渲染+钢笔淡彩 |
| 森林动物课堂 | `children-book.md` | 大头大眼, 叙事层次 |
| 睡前故事 | `children-book.md` | 想象力视觉化, 混合媒介 |
| 商务扁平 | `flat-style.md` | Corporate Memphis, 纯色块+3px描边 |
| 数据可视化 | `flat-style.md` | 饼图+图标, 几何装饰 |
| 城市地标 | `flat-style.md` | 日落暖色, 建筑扁平化 |

### 6. 像素艺术 (`references/prompts/pixel-art/`)

| 场景 | 文件 | 核心锚点 |
|------|------|----------|
| RPG 角色 | `character.md` | 16-bit, nearest-neighbor, 32色调色板 |
| 平台游戏场景 | `scene.md` | 视差卷轴, tile-based |
| 道具图标 | `game-asset.md` | 小尺寸, 清晰轮廓 |

### 7. 等距插画 (`references/prompts/isometric/`)

| 场景 | 文件 | 核心锚点 |
|------|------|----------|
| 极简卧室 | `room.md` | 2:1 网格, 剖面视角 |
| 城市街区 | `city.md` | 建筑群, 等距投影 |
| 游戏场景 | `game-scene.md` | 多层地形, 等距游戏视角 |

### 8. 体素/3D (`references/prompts/voxel-3d/`)

| 场景 | 文件 | 核心锚点 |
|------|------|----------|
| 自然景观 | `scene.md` | MagicaVoxel, ambient occlusion |
| 末日都市 | `scene.md` | 断裂截面, 蔓藤覆盖 |
| 海底世界 | `scene.md` | 体素 god rays, 半透明 voxel |
| 角色 | `character.md` | 立方体比例, 纯色面 |
| 浮空岛 | `landscape.md` | 锥形岩石, 吊桥连接 |

---

## 通用技巧速查

1. **垫图 + 编辑** — 先出初稿，再用编辑功能精细修改
2. **利用世界知识** — "生成一张抖音直播间截图"
3. **信息图三要素** — 模块化分区 + 圆角信息框 + 层级标题
4. **舍弃完美** — 添加"胶片颗粒感""手持失焦"增加真实感
5. **指定审美方向** — 用"1960 年代法国新浪潮海报"等风格锚点
6. **迭代流程** — 选 prompt → 调整主体 → 微调参数 → 效果不满意时查「常见避坑」→ 重新生成
