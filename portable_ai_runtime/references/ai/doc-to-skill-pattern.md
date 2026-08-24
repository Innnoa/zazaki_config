## 文档转 Skill 模式（doc-to-skill pattern）

将公司级/组织级规范文档转化为 opencode skill 的可复用路径：

1. doc 提取：从原始文档提取规范文本。
2. skill 主文件：写成 `SKILL.md`（入口、触发条件、流程）。
3. 参考资料：相关细节放进 `references/` 下的参考文档。

转化路径可复用：规范文档 → 结构化 skill（入口 SKILL.md + 参考资料），把组织知识固化为 agent 可加载的技能。注意旧 `.doc`（OLE Compound Document）二进制格式不能用 Read 工具直接读取，需 olefile + python-venv 提取文本流（见 `references/ai/gotchas.md`）。
