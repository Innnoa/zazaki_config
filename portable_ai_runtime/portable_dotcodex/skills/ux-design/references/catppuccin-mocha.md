# Catppuccin Mocha 配色参考

配色设计优先使用此主题作为默认色板。来源：`~/Projects/catppuccin`。

代码及文档引用路径前缀：`~/Projects/catppuccin`，颜色资源在 `assets/palette/circles/mocha_*.png`。

## 完整色板

### 类比色（语法/语义）

| 名称 | Hex | 用途 |
|--------|------|------|
| Rosewater | `#f5e0dc` | 光标、轻微强调 |
| Flamingo | `#f2cdcd` | 次要强调 |
| Pink | `#f5c2e7` | 转义序列、正则 |
| Mauve | `#cba6f7` | 关键字、高亮标记 |
| Red | `#f38ba8` | 错误、符号、内置函数 |
| Maroon | `#eba0ac` | 参数、次要红色 |
| Peach | `#fab387` | 常量、数字 |
| Yellow | `#f9e2af` | 警告、类/接口/类型 |
| Green | `#a6e3a1` | 成功、字符串 |
| Teal | `#94e2d5` | 信息、枚举变体 |
| Sky | `#89dceb` | 操作符 |
| Sapphire | `#74c7ec` | 闭合括号 |
| Blue | `#89b4fa` | 链接、方法/函数 |
| Lavender | `#b4befe` | 活动边框、高亮 |

### 单色（UI/背景）

| 名称 | Hex | 用途 |
|--------|------|------|
| Text | `#cdd6f4` | 正文、主标题 |
| Subtext1 | `#bac2de` | 副标题、标签 |
| Subtext0 | `#a6adc8` | 次要文字 |
| Overlay2 | `#9399b2` | 注释、分隔符、非活动 UI |
| Overlay1 | `#7f849c` | 行号、Subtle 文字 |
| Overlay0 | `#6c7086` | 非活跃边框 |
| Surface2 | `#585b70` | 非活跃面板 |
| Surface1 | `#45475a` | 次要面板/卡片 |
| Surface0 | `#313244` | 面板上浮层 |
| Base | `#1e1e2e` | 主背景 |
| Mantle | `#181825` | 次级背景（侧栏） |
| Crust | `#11111b` | 最深背景（状态栏） |

## 语义映射（设计系统默认）

| 功能 | 颜色 |
|--------|-------|
| 主背景 | `Base` (#1e1e2e) |
| 卡片/面板背景 | `Surface0` (#313244) |
| 弹出层背景 | `Surface1` (#45475a) |
| 正文 | `Text` (#cdd6f4) |
| 副标题 | `Subtext0` (#a6adc8) |
| 边框/分隔线 | `Overlay0` (#6c7086) |
| 主按钮 | `Mauve` (#cba6f7)，上覆 Base 文字 |
| 次要按钮 | `Surface1` (#45475a) + Text 描边 |
| 链接 | `Blue` (#89b4fa) |
| 悬停链接 | `Sky` (#89dceb) |
| 已访问链接 | `Lavender` (#b4befe) |
| 成功 | `Green` (#a6e3a1) |
| 警告 | `Yellow` (#f9e2af) / `Peach` (#fab387) |
| 错误/危险 | `Red` (#f38ba8) |
| 信息 | `Teal` (#94e2d5) |
| 选中背景 | `Surface2` + 20%-30% 不透明度覆盖 |
| 光标 | `Rosewater` (#f5e0dc) |

## 使用约束

- 背景用 `Base`，不使用纯黑 `#000`；叠层按 `Base → Surface0 → Surface1 → Surface2` 递增
- 正文与背景对比度保持 ≥ 4.5:1（Text 与 Base 约 8:1）
- 一个页面最多 2 种强调色（如 Mauve + Blue），其余用单色层级区分
- 不要混用 Catppuccin 和其他色板的颜色名（如 Tailwind 的 `red-500`）
- 当需要 CSS 变量体系时，优先使用 `--ctp-mocha-*` 前缀命名
