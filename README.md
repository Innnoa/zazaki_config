# zazaki_config

个人 dotfiles 与可移植 AI 治理运行时。

## 结构

```
zazaki_config/
├── editors/nvim/              # Neovim (LazyVim) 完整配置
├── tools/
│   ├── btop/                  # 系统监控 + Catppuccin 主题
│   ├── fastfetch/             # 系统信息 (路径已脱敏)
│   └── lazygit/               # Git TUI Catppuccin 配色
├── portable_ai_runtime/       # 可移植 AI 治理运行时
│   ├── AGENTS.md              # 通用治理入口
│   ├── rules/ai/              # 核心路由规则
│   ├── workflows/ai/          # 执行工作流
│   ├── references/ai/         # 参考文档
│   ├── skills/ scripts/       # 共享技能 & 验证脚本
│   ├── opencode/              # OpenCode 适配器
│   ├── adapters/              # Cursor / Claude Code / Copilot / Codex
│   └── install.sh             # 一键安装 (交互式 + CLI)
└── outputs/                   # gitignored 运行时产物
```

## 使用方式

### 编辑器 & 工具

```bash
ln -s ~/Projects/zazaki_config/editors/nvim ~/.config/nvim
ln -s ~/Projects/zazaki_config/tools/btop ~/.config/btop
```

### AI 治理运行时

```bash
cd portable_ai_runtime
./install.sh                     # 交互菜单: 选工具 → 选范围 → 确认
./install.sh opencode install    # CLI: 安装到 ~/.config/opencode/
```

支持 **OpenCode**、**Codex CLI**、**Cursor**、**Claude Code**、**GitHub Copilot**。详见 `portable_ai_runtime/README.md`。
