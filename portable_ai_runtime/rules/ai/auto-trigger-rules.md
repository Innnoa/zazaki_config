## 自动触发规则（auto-trigger-rules）

### 作用

定义"AI 自动加载 skill"的触发条件表。本文件只负责**何时加载**；各 skill 的**如何执行**由 skill 内部规则自行承载（humanizer-zh 量化门槛、human-writing 创作管线、parse-api 工作流、ux-design/apple-design 规范均在其 SKILL.md 内，本文件不重复）。

### 自动触发条件

| 触发场景 | 自动激活 | 负责层 |
|---|---|---|
| 电商价格/商品/评价/库存（eBay、Walmart、Amazon、Home Depot）、物流（Maersk）、房产（Zillow）、市场/金融（CME、FRED）、天气、NASA 数据；"抓取某网站"或"结构化获取某 URL 数据"；提到 parse.bot、/dispatch、scraper、credits、Parse API | `parse-api` | 结构化数据获取 |
| 网络小说/网文创作（写章节、码字更新、续写、爽文、系统文）；小说/故事/虚构创作；知乎回答、公众号文章、论坛长帖、博客、评测、科普、教程等中文长文；要求"写得像人写的/有活人感/自然中文韵律" | `human-writing` | 中文创作（活人感写作） |
| 生成中文自然语言输出（文章、博客、文案、邮件、说明、摘要、社交内容、长段回复） | `humanizer-zh` | 自动去 AI 味 |
| 设计/实现/审查 页面、组件、表单、导航、仪表盘、落地页；前端开发（React/Vue/HTML）；修改样式、布局、重构组件；纯交互/流程设计 | `ux-design` | UX 法则（显式 Apple/极简/现代视觉风格请求时叠加 `apple-design`） |
| 纯样式调整（仅改视觉令牌/静态样式，无组件结构、布局逻辑、交互或表单流程变化） | `apple-design`（主） | 仅视觉系统 |
| 图像理解/视觉分析（描述图片、分析截图、OCR 增强、视觉缺陷诊断、设计稿转代码、UI 截图审查）；任何带图片附件的任务 | `vision-analyze` | 多模态理解（deepseek-vision） |
| 画流程图/架构图/时序图/ER 图/思维导图/网络拓扑图/甘特图等结构化图表；提到 drawio、diagrams.net、diagram、帮我画个图 | `diagram-drawio` | 结构化图表生成 |
| 抓包/协议分析/网络流量分析/网卡监听/分析 pcap 文件；提到 zgrab、zazaki-grab、Wireshark、tcpdump 类需求 | `zazaki-grab`（MCP，11 工具） | 抓包/协议分析 |
| 个人知识库内容检索：`Knowledge_base` Obsidian 笔记、乐理与学习笔记、`PathLearn_Nav`、`Personalized-learning-navigation-system`；"我的笔记/知识库里怎么写的"；需引用个人笔记原文作答 | `zazaki-rag`（MCP，4 工具） | 本地知识检索（离线语料） |
| Ansible 部署/巡检、SSH 批量运维、Linux/服务器配置、容器 runner、配置模板、备份恢复、cron 或 systemd timer 自动化 | `ansible-ssh-deployment` | 运维部署经验（以项目具体规则为准） |

> 注：`zazaki-grab` 与 `zazaki-rag` 都是 **MCP 工具集（非 skill）**——接线后常驻可用，这两行定义的是"任务 → 工具"的路由偏好（AI 遇到相关任务时优先调用，无需手动命令）；与上表 skills 的"关键词自动加载"机制不同，不存在加载动作。实时抓包需先 `~/Projects/zazaki_grab/scripts/setup_cap.sh` 提权；`zazaki-rag` 的语料范围与"何时不应调用"由工具描述自身承载（`/home/zazaki/Projects/zazaki_rag/src/zazaki_rag/mcp_server.py` 的 `search_knowledge` docstring），本文件不重复。

### 不触发

- 读网页正文/单页内容：用 fetch / lightpanda（不消耗 parse-api credits）
- 数据已有官方 API：优先官方接口
- 生成/编辑图像（无图需造图）：用 `gptimage2-prompting`，不走 vision-analyze
- 像素级生图（插画/海报/概念图）：用 `gptimage2-prompting`，不走 diagram-drawio（那是结构化图表的职责）
- 需先采集页面/截屏：用 Playwright MCP 截图后再走 vision-analyze
- 技术文档、代码注释、短事实性回答（<3 句）：humanizer-zh 与 human-writing 都不触发
- 普通应用代码修改或项目已有明确专用流程：不因关键词强行触发；项目专属规则优先
- 用户明确指定其他 skill 或要求"别用 skill"：听用户的
- 语料范围外的检索（opencode 与工具链本身、通用编程库、公网信息、需联网核实的资料）：不调用 `zazaki-rag`，改用 context7 / websearch / @librarian

### 触发消解（中文写作域）

- 请求含"写/续写/创作/码字/更新/写一章" + 文体词 → `human-writing`
- 请求含"改/润色/去AI味/太AI/不自然/像人写的" + 已有文本 → `humanizer-zh`
- 模糊场景（如"把这章改自然点"）：先看文本来源——本会话 `human-writing` 产出的创作稿 → `humanizer-zh` 局部修补；来源不明的旧稿 → `humanizer-zh` 全套流程
- UI 冲突时以 `ux-design` 为准（视觉服从交互）；配色默认 Catppuccin Mocha，用户明确要求亮色/浅色模式时允许 Latte（与 apple-design skill 的亮色例外一致）

### MCP 工具选择：context7 vs librarian

- 新库接入、API 变化确认、文档真实性核对（需要官方文档精确校准）→ context7
- 生态对比、方案调研、外部最佳实践、最新资讯收集 → @librarian
- 两者均可时：@librarian 兜底（context7 偏向精确文档核对，librarian 偏向广泛调研）
- context7 不可用（连接失败/超时/无结果）时：回退 @librarian

### 检验句

问自己：当前任务命中了上表哪个触发场景？对应的 skill 是否已加载？执行细节是否由该 skill 内部规则承载（而不是在本规则文件里重复）？
