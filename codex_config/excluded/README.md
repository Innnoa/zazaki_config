# Excluded From Portable Pack

这些文件没有直接打包进 `portable_dotcodex/`，原因是它们依赖当前机器、当前会话或当前审计历史。

## 故意排除的内容

- `config.toml` 里的真实 `experimental_bearer_token`
- `config.toml` 中当前机器的 `[projects."..."] trust_level` 列表
- `.vibeskills/install-ledger.json`
- `.vibeskills/mcp-auto-provision.json`
- `tmp/serena-home`
- `outputs/runtime/vibe-sessions/`
- 当前活跃的 `AI_GUIDE.md`
- 当前活跃的 `CURRENT_TASK.md`
- 当前活跃的 `DECISIONS.md`

## 原因

- 这些文件里包含敏感信息、本机绝对路径或一次性运行状态。
- 直接复制到别的设备，容易造成路径失效、错误信任或历史状态污染。

## 如果确实需要

- `trust_level`：在新设备的 `config.toml` 中按实际项目重新补。
- `.vibeskills/*.json`：在新设备重新执行对应安装流程，让它们按新路径再生成。
- `AI_GUIDE.md` 等状态文件：从 `state-templates/` 初始化，不建议直接复制旧历史。
