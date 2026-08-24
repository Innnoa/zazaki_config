## 自动 Parse API 数据获取规则

### 作用

指示 AI 在用户需要"获取网站结构化数据/抓取/查价格"时，自动加载 `parse-api` skill 并按工作流调用 Parse（parse.bot），无需用户显式说明。

### 自动触发条件

以下任一情况自动激活 `parse-api` skill：

| 触发场景 | 处理 |
|---|---|
| 查电商价格/商品/评价/库存（eBay、Walmart、Amazon、Home Depot 等） | `parse-api` |
| 物流追踪（Maersk）、房产（Zillow）、市场/金融数据（CME、FRED）、天气、NASA 数据 | `parse-api` |
| 用户要求"抓取某网站数据"或"结构化获取某 URL 的数据" | `parse-api` |
| 用户提到 parse.bot、/dispatch、scraper、credits、Parse API | `parse-api` |

### 不触发

- 读取网页正文/单页内容：用 fetch / lightpanda（免费，不消耗 credits）
- 数据已有官方 API：优先官方接口

### 自动执行规则

1. 加载 `parse-api` skill，按其工作流执行：先搜 marketplace（免费）→ 命中直接调用；未命中 → `/dispatch` 构建 → 轮询 → 调用。
2. 调用前确认 `$PARSE_API_KEY` 可用；调用后留意 `X-Credits-Remaining` 余额。
3. 目标网站返回 502 视为对方问题，先重试，不急着换方案。

### 检验句

用户要"网站数据"时，问自己：是读网页正文（fetch/lightpanda）还是结构化数据（parse-api）？若为后者且无官方 API，是否已加载 `parse-api` skill 并按工作流执行？
