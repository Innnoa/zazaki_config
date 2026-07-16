# Cursor 适配器

## 安装

```bash
# 在你的项目根目录
cp ~/zazaki_config/adapters/cursor/.cursorrules ./.cursorrules

# 同时链接核心规则目录（可选，Cursor 可直接读取）
ln -s ~/zazaki_config/rules ./rules
ln -s ~/zazaki_config/references ./references
ln -s ~/zazaki_config/workflows ./workflows
```

## 说明

Cursor 在项目根目录自动读取 `.cursorrules`。核心治理规则文件通过相对路径引用。
