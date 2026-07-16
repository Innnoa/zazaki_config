---
name: frontend-regulation
description: >
  Use when the user is doing frontend development with Ant Design / Ant Design Pro — whether in
  English ("frontend", "new page", "new component", "fix style", "add feature", "UI component",
  "Ant Design", "Ant Design Pro", "ProComponents", "CSS-in-JS", "createStyles", "frontend build",
  "frontend deploy", "frontend project", "react component") or in Chinese
  ("前端开发", "前端", "新建页面", "修改页面", "新组件", "修改组件", "改样式", "加功能",
  "写前端", "前端项目", "前端工程", "Ant Design", "Antd").
  This skill enforces company frontend development specifications covering code standards,
  UI/UX consistency, interaction patterns, CSS-in-JS usage, project structure, and build
  configuration for Ant Design Pro based projects.
---

# 前端开发规范

公司前端开发规范，覆盖代码规范、UI 一致性、交互模式、CSS-in-JS、工程配置。基于
Ant Design Pro 技术栈。

## Session Discipline

每个新前端任务——即使是同一会话的第 N 轮——必须重读本文件并逐条对照适用规范。

检验句：`我写的代码和本规范逐条对照过了吗？`

## 代码规范

### 必须执行的检查
- ESLint + Prettier 配置正确，无报错
- 生产/测试环境不得出现 `debugger` 和 `console.log`
- F12 控制台无红色错误（第三方插件导致的除外）
- `map` 等循环必须有 `key`

### 文件与代码组织
- 单文件不超过 **800 行**，超出需提取组件或模块
- 公共资源（字体、字号、颜色等）提取到 **token** 中（参考 `references/cssinjs-guide.md`）
- 公共组件在项目初期定义好，开发时复用

### 注释规范
- 关键逻辑必须加注释，说明实现思路
- 每个方法、模块、组件加注释
- 避免过度注释，保持代码自解释性

### 浏览器存储
- 存储在浏览器本地（localStorage、IndexedDB 等）的数据，用完必须即时清理

## UI 规范

### 组件选型优先级
当有界面需求但暂缺 UX 设计时，组件嵌套优先级：

1. **Ant Design Pro** — https://preview.pro.ant.design/dashboard/analysis
2. **ProComponents** — https://procomponents.ant.design/components
3. **Ant Design** — https://ant-design.antgroup.com/components/overview-cn/

### 对齐与一致性
- 界面横平竖直：水平居中对齐，垂直左右对齐
- 全系统风格统一：同类组件（如 Table）应有一致的外观和行为
- 最小宽度 **1000px**，低于此宽度出滚动条保证基础样式

### 多分辨率适配
- 界面设计需考虑不同分辨率
- 每个区域设置合理的最小宽度

### 字体
- 默认字体：`"Microsoft JhengHei", 微軟正黑體, "Arial", sans-serif`
- 公共字体设置在 token 中

## 交互规范

### 权限与报错提示
- 多选操作时，无权限项用**确认弹窗**提示用户哪些项无权限（保证用户能看到）
- 后端返回的报错信息用**确认弹窗**提示用户（保证用户能看到）

### 危险操作确认
- 删除、提交等重要操作必须有**确认 + 取消**两个按钮的警告确认框

### 图标按钮
- 图标按钮鼠标悬停时必须有 tooltip 文字提示

### 按钮 Loading
- AJAX 请求时按钮需显示 loading 状态，防止双击重复提交

### 页面状态保持
- 列表页进入详情页后回退，列表页保持之前的状态（筛选、分页等）

## CSS-in-JS 规范

样式统一使用 CSS-in-JS（`antd-style` 的 `createStyles`），详细写法参考：
- `references/cssinjs-guide.md`

核心要点：
- 用 token 管理公共样式变量，避免样式污染
- 全局主题在 `config.ts` 中配置 `antd.theme.token` + `components`
- 布局 token 在 `DefaultSettings.ts` 中配置 proLayout
- 局部样式用 `createStyles`，tsx 中用 `useToken()` 取 Design Token

## 工程规范

### 目录结构
- 参考项目既有目录规范（`前端项目结构.eddx`）

### Git 提交
- 完成一个功能提交一次
- 提交注释清晰描述改动内容

### README.md
- 每个前端项目必须有 README.md，参考项目模板书写

### 打包与部署
- 参考项目 Dockerfile 和 nginx.conf.template 配置
- 确保每次重新打包后浏览器缓存得到正确处理
- 其他配置按项目实际情况调整

## 使用方式

1. 确认任务属于前端开发范畴
2. 通读本规范，识别与当前任务相关的规范条目
3. 编写代码时逐条对照适用规范
4. 完成后用检验句自检：`我写的代码和本规范逐条对照过了吗？`
5. CSS-in-JS 写法有疑问时查阅 `references/cssinjs-guide.md`
