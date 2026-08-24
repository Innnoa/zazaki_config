## Vibe 路径分类规则

> **触发频率：低（设计意图）** — 此文件仅用于 `skills/vibe/config/*.json` 的打包/安装场景。
> 日常 AI 任务不会触发此规则，勿误判为死规则。

### 作用

为 `skills/vibe/config/*.json` 中出现的路径引用建立单一路径分类规则，避免把 install-time projection、runtime-generated artifact、external-tooling evidence 与本地必需路径混成同一类“缺文件”。

### 适用范围

- `skills/vibe/config/*.json`
- 以及引用这些配置并据此做治理判断的检查脚本、workflow 与验证汇报

### 分类目标

对每个路径引用，优先归入以下一类：

1. `local_required`
2. `runtime_generated`
3. `projection_only`
4. `install_only`
5. `external_tooling`
6. `optional_material`

一条路径只能按一个主分类处理；不要同时按“本地必需”和“投影目标”双重计算。

### 分类定义

#### 1. `local_required`

- 含义：当前仓内 canonical `skills/vibe` 根下，本地就应该存在的静态文件或目录锚点
- 例如：`config/*.json`、`scripts/runtime/*`、`scripts/router/*`、`protocols/*`、`templates/*`、`schemas/*`
- 处理：缺失即报错

#### 2. `runtime_generated`

- 含义：由 runtime、cleanup、verification 或执行过程生成的产物路径
- 常见特征：位于 `outputs/`，或带 `{run_id}`、`{date}`、`{slug}` 等占位
- 处理：
  - 文件本身缺失不直接报错
  - 但其父级目录锚点若按当前仓约定应存在，可要求存在最小目录锚点

#### 3. `projection_only`

- 含义：描述投影后的目标布局、resolver root、payload target 或 public surface target 的路径，不代表当前 canonical 仓内必须存在同名实体
- 常见特征：
  - `skills/vibe`
  - `skills/vibe/bundled/skills`
  - `bundled/skills/vibe`
  - `skills`、`commands` 这类打包后目标根
- 处理：不按本地缺失报错；只检查其语义是否和相应 packaging 字段一致

#### 4. `install_only`

- 含义：只在 install / materialization / compatibility payload 阶段才要求存在或生成的路径
- 常见特征：
  - `generated_compatibility`
  - `allow_installed_only`
  - `target_relpath` / `receipt_relpath` 中明确指向安装后布局
- 处理：不把当前 canonical 仓缺失误报为错误；仅在安装态验证或安装脚本验证中检查

#### 5. `external_tooling`

- 含义：外部调研、上游对照、discovery corpus、external memo、评估资料等材料层路径
- 常见特征：
  - `docs/external-tooling/*`
  - `docs/governance/*` 中只用于证据或资料层的语料
  - `references/*` 中明确是外部语料或评估资料的条目
- 处理：默认不按本地缺失报 runtime/blocking 错误；只在对应 material / evidence 流程需要时再单独检查

#### 6. `optional_material`

- 含义：明确标记为 `optional: true`，或语义上仅是可选 lockfile / 说明材料 / preview-guidance 资产
- 处理：缺失不报错，可选地记为 note

### 判断顺序

必须按以下顺序判断，避免先宽后窄造成误判：

1. 含模板占位或位于 `outputs/`：`runtime_generated`
2. 明确位于 install / generated compatibility / installed runtime target：`install_only`
3. 明确是 payload target / projection root / resolver root：`projection_only`
4. 明确是外部资料、discovery、upstream memo：`external_tooling`
5. 明确标记可选：`optional_material`
6. 其余落回 `local_required`

检验：我分类这条路径时，是按 1→6 的判断顺序来的，还是先宽后窄跳到了结论？

### 禁止事项

- 不得把 `apps/*`、`packages/*`、`dist/*`、`adapters/*` 这类上游或安装投影资产直接当成本地 canonical 缺文件
- 不得为了让检查通过而伪造整套上游 pack
- 不得把 `runtime_generated` 产物的当前缺失误报成“本地配置错误”
- 不得把 `projection_only` 和 `install_only` 资产补成看似真实的本地权威面

### 验证要求

- 修改本规则或 `skills/vibe/config/*.json` 路径边界时，必须运行专门的 `skills/vibe` 路径分类检查脚本
- 汇报时至少写出：检查范围、分类规则版本、错误数、被豁免的 projection / install-only / external-tooling 数量
