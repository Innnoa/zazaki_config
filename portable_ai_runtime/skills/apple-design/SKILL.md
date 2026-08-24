---
name: apple-design
description: Use when designing or implementing UI with a modern minimalist visual style. Provides concrete CSS design tokens (colors, typography, spacing, glassmorphism, animations) for building polished interfaces. Complements ux-design (which handles UX laws/principles); this skill handles visual implementation. Triggers on "Apple风格", "极简设计", "现代UI", "设计系统", "视觉风格", "apple design", "minimal UI".
---

# Apple-Class 极简设计系统（Catppuccin Mocha 配色版）

基于 Apple 设计语言的现代极简主义视觉实现层。专注于"看起来怎么样"——颜色、字体、间距、玻璃态、动画。UX 法则审查由 `ux-design` skill 负责。

**默认配色：Catppuccin Mocha。** 有亮色模式需求时，切换为 Catppuccin Latte 色板（见 `../ux-design/references/catppuccin-mocha.md`）。

---

## 核心设计理念

- 极致简约 — 去除一切不必要的元素
- 功能至上 — 每个元素都有明确目的
- 精确美学 — 像素级完美对齐
- 情感共鸣 — 微妙但有意义的交互反馈

---

## 颜色系统（Catppuccin Mocha）

```css
/* ---------- UI 层级 ---------- */
--bg-base:       #1e1e2e;   /* 主背景 */
--bg-mantle:     #181825;   /* 次级背景（侧栏） */
--bg-crust:      #11111b;   /* 最深背景（状态栏） */
--bg-surface0:   #313244;   /* 卡片/面板背景 */
--bg-surface1:   #45475a;   /* 弹出层背景 */
--bg-surface2:   #585b70;   /* 悬浮态背景 */

/* ---------- 文字层级 ---------- */
--text-primary:  #cdd6f4;   /* 正文/主标题 */
--text-subtext0: #a6adc8;   /* 副标题/次要文字 */
--text-overlay0: #6c7086;   /* 注释/非活跃文字 */
--text-overlay1: #7f849c;   /* 行号/Subtle 文字 */

/* ---------- 语义色 ---------- */
--accent:        #cba6f7;   /* Mauve — 主交互色（按钮、焦点环） */
--accent-text:   #1e1e2e;   /* 强调色上的文字（Base） */
--link:          #89b4fa;   /* Blue — 链接 */
--link-hover:    #89dceb;   /* Sky — 悬停链接 */
--success:       #a6e3a1;   /* Green — 成功 */
--warning:       #f9e2af;   /* Yellow — 警告 */
--warning-alt:   #fab387;   /* Peach — 警告（强调） */
--error:         #f38ba8;   /* Red — 错误/危险 */
--info:          #94e2d5;   /* Teal — 信息 */

/* ---------- 边框 ---------- */
--border:        #6c7086;   /* Overlay0 — 边框、分隔线 */
--border-focus:  #cba6f7;   /* Mauve — 焦点边框 */

/* ---------- 玻璃态专用 ---------- */
--glass-bg:      rgba(30, 30, 46, 0.75);   /* Base + 透明度 */
--glass-border:  rgba(108, 112, 134, 0.12); /* Overlay0 + 透明度 */
```

### 配色原则

- 一个页面最多 **2 种强调色**（如 Mauve + Blue），其余用单色层级区分
- 正文与背景对比度 ≥ 4.5:1
- 叠层按 `Base → Surface0 → Surface1 → Surface2` 递增
- 不要混用此色板和其他色板的颜色名

---

## 字体系统

```css
/* 响应式字体大小 — 基于 clamp() 的完美缩放 */
--font-display:  clamp(2.25rem, 5vw, 5rem);      /* 36px - 80px */
--font-headline: clamp(1.75rem, 4vw, 3rem);       /* 28px - 48px */
--font-title:    clamp(1.125rem, 2.5vw, 1.5rem);  /* 18px - 24px */
--font-body:     clamp(0.875rem, 2vw, 1.125rem);  /* 14px - 18px */
--font-caption:  clamp(0.75rem, 1.5vw, 0.875rem); /* 12px - 14px */

/* 对应 CSS 类 */
.text-display  { font-size: var(--font-display);  font-weight: 600; line-height: 1.1; letter-spacing: -0.025em; }
.text-headline { font-size: var(--font-headline); font-weight: 600; line-height: 1.2; letter-spacing: -0.02em; }
.text-title    { font-size: var(--font-title);    font-weight: 600; line-height: 1.3; letter-spacing: -0.01em; }
.text-body     { font-size: var(--font-body);     font-weight: 400; line-height: 1.5; }
.text-caption  { font-size: var(--font-caption);  font-weight: 400; line-height: 1.4; color: var(--text-subtext0); }
```

### 字体使用原则

- 优先使用系统字体栈：`-apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", sans-serif`
- 仅使用 400（常规）和 600（半粗）两种字重
- 大标题使用负字距，提升现代感

---

## 布局系统（8px 网格）

```css
--space-xs:  4px;   /* 0.5 单位 */
--space-sm:  8px;   /* 1 单位 */
--space-md:  16px;  /* 2 单位 */
--space-lg:  24px;  /* 3 单位 */
--space-xl:  32px;  /* 4 单位 */
--space-2xl: 48px;  /* 6 单位 */
--space-3xl: 64px;  /* 8 单位 */
--space-4xl: 96px;  /* 12 单位 */
```

```css
/* 响应式容器 */
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

@media (max-width: 768px) {
  .container { padding: 0 16px; }
}

/* 响应式网格 */
.grid {
  display: grid;
  gap: var(--space-lg);
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
}
```

---

## 玻璃态设计

```css
/* 基础玻璃效果 */
.glass {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.3);
  backdrop-filter: blur(20px) saturate(120%);
  -webkit-backdrop-filter: blur(20px) saturate(120%);
  transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
}

.glass:hover {
  box-shadow: 0 4px 12px 0 rgb(0 0 0 / 0.4);
  transform: translateY(-0.5px);
}

/* 玻璃卡片 */
.glass-card {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 12px;
  padding: 32px;
  box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.3);
  backdrop-filter: blur(20px) saturate(120%);
  transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
}

.glass-card:hover {
  box-shadow: 0 4px 12px 0 rgb(0 0 0 / 0.4);
  transform: translateY(-0.5px);
}

/* 玻璃按钮 */
.glass-button {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 12px;
  padding: 12px 16px;
  color: var(--text-primary);
  transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
}

.glass-button:hover {
  transform: translateY(-0.5px);
  background: var(--bg-surface0);
}

/* 主要操作按钮 */
.glass-button-primary {
  background: var(--accent);
  color: var(--accent-text);
  border: 1px solid var(--accent);
  border-radius: 12px;
  padding: 12px 16px;
  transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
}

.glass-button-primary:hover {
  background: color-mix(in srgb, var(--accent) 85%, white);
  transform: translateY(-0.5px);
  box-shadow: 0 4px 12px 0 rgb(203 166 247 / 0.3);
}
```

---

## 动画系统

```css
/* iOS 缓动函数 */
--ease-out:    cubic-bezier(0.0, 0.0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0.0, 0.2, 1);
--ease-spring: cubic-bezier(0.175, 0.885, 0.32, 1.275);

/* 渐显动画 */
@keyframes fade-in-up {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}

@keyframes scale-in {
  from { opacity: 0; transform: scale(0.95); }
  to   { opacity: 1; transform: scale(1); }
}

.animate-fade-in { animation: fade-in-up 0.6s var(--ease-out) forwards; }
.animate-scale-in { animation: scale-in 0.4s var(--ease-out) forwards; }
```

### 交互动画原则

- hover 时元素向上移动 0.5px，阴影加深
- 所有状态变化 ≤ 0.3s
- 支持 `prefers-reduced-motion`
- 使用 `transform` 和 `box-shadow`，而非颜色突变

---

## 区块交替背景

```css
/* 区块间交替使用 Base 和 Surface0，实现视觉分隔 */
.section-primary   { background: var(--bg-base); }
.section-secondary { background: var(--bg-surface0); }
```

---

## 渐进式显示

```html
<!-- 组件级渐显，带递增延迟 -->
<div class="animate-fade-in" style="animation-delay: 0.1s">
  <div class="glass-card">卡片 1</div>
</div>
<div class="animate-fade-in" style="animation-delay: 0.2s">
  <div class="glass-card">卡片 2</div>
</div>
<div class="animate-fade-in" style="animation-delay: 0.3s">
  <div class="glass-card">卡片 3</div>
</div>
```

---

## 移动端优化

- 最小触摸目标：**44px**（Apple HIG 标准）
- 移动端空间压缩：4xl → 3xl, 3xl → 2xl, 2xl → xl, xl → lg
- 容器 padding：桌面 24px，移动端 16px

---

## 与 ux-design 的分工

| 层 | 负责 skill | 典型问题 |
|---|---|---|
| UX 法则 | `ux-design` | 这个按钮的位置符合 Fitts 定律吗？表单字段符合 Miller's Law 吗？ |
| 视觉实现 | `apple-design` | 这个按钮用什么颜色、字号、圆角、动画？玻璃态透明度多少？ |

两个 skill 同时激活时，`ux-design` 审可用性，`apple-design` 实现视觉。如有冲突，以 `ux-design` 的 UX 判断为准（视觉服从交互）。

---

## 亮色模式

当需要亮色模式时，将色板切换为 Catppuccin Latte：

```css
/* Latte 关键颜色映射 */
--bg-base:       #eff1f5;
--bg-surface0:   #ccd0da;
--text-primary:  #4c4f69;
--text-subtext0: #6c6f85;
--accent:        #8839ef;  /* Mauve (Latte) */
```

详细色板见 `../ux-design/references/catppuccin-mocha.md`。
