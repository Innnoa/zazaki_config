# zazaki_config

可复用的个人 dotfiles 与 AI 治理配置。

## 结构

```
zazaki_config/
├── editors/
│   └── nvim/              # Neovim (LazyVim) 完整配置
├── tools/
│   ├── btop/              # 系统监控 + Catppuccin 主题
│   ├── fastfetch/         # 系统信息 (路径已脱敏)
│   └── lazygit/           # Git TUI Catppuccin 配色
└── portable_ai_runtime/   # OpenCode + Codex 可移植治理包
    └── portable_dotcodex/ # AGENTS.md、rules、workflows、skills 等
```

## 使用方式

各子目录对应 `~/.config/` 下的同名目录，软链接即可：

```bash
ln -s ~/Projects/zazaki_config/editors/nvim ~/.config/nvim
ln -s ~/Projects/zazaki_config/tools/btop ~/.config/btop
ln -s ~/Projects/zazaki_config/tools/lazygit/config.yml ~/.config/lazygit/config.yml
ln -s ~/Projects/zazaki_config/tools/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
```

`portable_ai_runtime/` 的安装说明见 `portable_ai_runtime/README.md`。
