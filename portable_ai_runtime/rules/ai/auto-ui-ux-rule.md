## 自动 UI/UX 设计规则

### 作用

指示 AI 在涉及界面设计、前端组件实现或 UI 审查时，自动加载设计相关 skill，无需用户显式调用。

### 自动触发条件

以下任一情况自动激活对应 skill：

**任何涉及界面设计/实现/审查时，两个 skill 同时激活：**

| 触发场景 | 自动激活 | 负责层 |
|---|---|---|
| 设计/实现 页面、组件、表单、导航、仪表盘 | `ux-design` + `apple-design` | UX 法则 + 视觉实现 |
| 审查/评估 已有 UI | `ux-design` + `apple-design` | 可用性审查 + 视觉审查 |
| 前端开发（React/Vue/HTML 组件） | `ux-design` + `apple-design` | 交互合理性 + 视觉规范 |
| 落地页、首页、定价页、注册页 | `ux-design` + `apple-design` | 完整设计审查 |
| 修改样式、调整布局、重构组件 | `apple-design`（主） + `ux-design`（辅） | 视觉优先，交互不退化 |
| 纯交互/流程设计（无视觉） | `ux-design` | 仅 UX 法则 |
| 纯样式调整（无交互变化） | `apple-design` | 仅视觉系统 |

### 分工原则

- `ux-design` 决定"对不对"——可用性、认知负荷、决策效率
- `apple-design` 决定"看起来怎么样"——颜色、间距、动画、玻璃态
- 冲突时以 `ux-design` 为准（视觉服从交互）
- 配色始终为 Catppuccin Mocha

### 自动执行规则

1. **设计/实现阶段**：在写任何 UI 代码前，自动对照 `ux-design` 五层法则检查关键交互点，然后按 `apple-design` 的 8px 网格、颜色系统、字体层级和动画规范实现。

2. **审查阶段**：按 `ux-design` Common Tasks 路由逐层审查，同时用 `apple-design` 检查颜色一致性、间距对齐、动画合理性。

3. **默认交付**：UI 代码自动使用 Catppuccin Mocha 颜色变量、clamp() 响应式字体、8px 网格间距、12px 圆角、iOS 缓动动画。玻璃态（backdrop-filter: blur(20px)）用于卡片和弹出层。

### 检验句

写 UI 代码前，问自己：主要交互是否符合 Fitts 定律？颜色是否来自 Catppuccin Mocha 色板？间距是 8 的倍数吗？按钮最小触摸目标 44px 了吗？
