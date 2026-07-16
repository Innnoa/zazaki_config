# OpenCode 适配器

## 文件

- `opencode.template.jsonc` — OpenCode 配置模板
- `plugins/session-governance.ts` — 会话治理插件
- `agents/` — Agent 定义
- `commands/` — 命令定义
- `mcp/` — MCP 服务器配置
- `prompts/` — 安全模式提示

## 安装

```bash
# 使用安装脚本
./install.sh opencode install
```

## 配置说明

安装脚本将核心规则目录（rules/, workflows/, references/）和 OpenCode 配置文件复制到 `~/.config/opencode/`。
首次安装后需编辑 `opencode.json`：替换 provider API key 和 MCP 路径占位符。
