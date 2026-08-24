---
name: parse-api
description: Use when the user needs structured data from websites without a convenient official API — e-commerce prices/products/reviews/inventory (eBay, Walmart, Amazon, Home Depot), shipping tracking (Maersk), real estate (Zillow), market/financial data (CME, FRED), weather, NASA — or wants to scrape/act on any URL via Parse (parse.bot) as typed JSON. Triggers on 查价格/商品/电商数据、结构化抓取网站数据、物流追踪、房产数据、市场数据、parse.bot、/dispatch、scraper、credits. Do not use for plain web page reading (use fetch/lightpanda) or data already covered by an official API.
---

# Parse API Skill

把任何网站变成可调用 REST API 的中转服务（3k+ 现成 API + 按 URL 构建新 API）。所有请求走 `https://api.parse.bot`，按 credits 计费。

## When to Use

- 用户要某平台的结构化数据且无方便官方 API（价格、商品、评价、追踪、房产等）
- 用户要"抓取/结构化获取某个 URL 的数据"
- 用户提到 parse.bot、/dispatch、scraper、credits

**不适用**：读网页正文 → 用 fetch / lightpanda（免费）；数据有官方 API → 先走官方。

## 认证

- key 从环境变量读取 `$PARSE_API_KEY`（存于 `~/.config/opencode/provider-secrets.env`，`.zshrc` 启动链 source），请求头 `X-API-Key: $PARSE_API_KEY`
- 免费档：200 credits、5 req/min；每次响应头 `X-Credits-Remaining` 显示余额
- marketplace 搜索（`/marketplace/apis`）免费，无需 key

## 工作流

### A. 用现成 API（首选，免构建）

1. 搜索：`curl -s "https://api.parse.bot/marketplace/apis?q=<关键词>"` 或浏览 https://parse.bot/marketplace
2. 取详情：`GET /marketplace/apis/{id}` → 得 `canonical_scraper_id` 与端点列表（含参数、return_schema）
3. 调用（GET 端点用 query 参数，POST 端点用 JSON body）：

```bash
curl -s "https://api.parse.bot/scraper/{scraper_id}/{endpoint}?param=value" \
  -H "X-API-Key: $PARSE_API_KEY"
```

### B. 构建新 API（marketplace 无命中时）

1. `POST /dispatch`，body 含 URL + 数据描述（附 `endpoint_examples` 可显著加快构建）：

```bash
curl -s -X POST https://api.parse.bot/dispatch \
  -H "X-API-Key: $PARSE_API_KEY" -H "Content-Type: application/json" \
  -d '{"url":"https://example.com","description":"要什么数据","endpoint_examples":[{"name":"search","method":"POST","input":{"query":"iphone"}}]}'
```

2. 轮询 `GET /dispatch/tasks/{task_id}`（每 3–5 秒）至 `status: completed`，取 `generated_api.scraper_id` 和端点；`needs_input` 时用 `POST /dispatch/{task_id}` 回答 `user_input_prompt` 后继续
3. 调用同 A.3

### C. 修订

改行为用 `POST /dispatch/tasks/{task_id}/revise` 自然语言描述，轮询同 B.2（`scraper_id` 不变）。

## 错误处理

| 状态码 | 含义 | 处理 |
|---|---|---|
| 401 | key 缺失/无效 | 检查 `$PARSE_API_KEY` |
| 404 | 路径错误 | 确认 `api.parse.bot` + 精确路径（非 `/api/` 前缀） |
| 502 | 目标网站失败 | 重试；反复失败则换参数/时间（不是 Parse 的错） |
| 500 | Parse 内部错误 | 稍后重试 |
| 429 | 超限速/超额 | 等待或升级计划 |

## Common Mistakes

- 读网页正文误用 Parse（浪费 credits）→ 用 fetch/lightpanda
- GET 端点传 JSON body → 应放 query 参数
- 不查 `X-Credits-Remaining` 导致额度耗尽
- 忽略 `needs_input`：构建需要测试样例时先回答再轮询，别当失败重发
