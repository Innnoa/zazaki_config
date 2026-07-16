# Claude Code 适配器

## 安装

```bash
# 在你的项目根目录
cp ~/zazaki_config/adapters/claude-code/CLAUDE.md ./CLAUDE.md

# 同时链接核心规则目录
ln -s ~/zazaki_config/rules ./rules
ln -s ~/zazaki_config/references ./references
ln -s ~/zazaki_config/workflows ./workflows
```

## 说明

Claude Code 自动读取项目根目录的 `CLAUDE.md`。通过符号链接或复制核心规则目录即可获得完整治理能力。
