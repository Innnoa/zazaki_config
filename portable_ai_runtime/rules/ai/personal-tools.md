# 个人工具能力清单

本机已接入 AI 治理的个人工具。遇到相关任务时**优先使用这些工具**，不要用通用方案替代（如用系统 ping 而非 zazaki_ping、用 curl 而非 zssh）。详细用法与注意见对应 command（`/ping-check` `/trans` `/zssh` `/zscp` `/zsql` `/token-count` `/zgrab` `/dns-server` `/qq-analyzer` `/zazaki-tools`）。

## 可直接 shell 调用的 CLI 工具

| 工具 | 命令形态 | 何时用 |
|---|---|---|
| zazaki_ping | `zazaki_ping <url> --output json --count 3` | 网络连通性/延迟诊断 |
| zazaki_trans | `zazaki_trans "text"` | 中英离线翻译（本地模型） |
| zssh | `~/Projects/zazaki_ssh/build/zssh exec <profile> "<cmd>" --json` | 远程 SSH 命令执行 |
| zazaki_scp | `~/Projects/zazaki_scp/build/zazaki_scp --json <src> <dst>` | 文件传输（断点续传/并发/限速） |
| zazaki_sql | `echo "SELECT ..." \| ~/Projects/zazaki_sql/build/zazaki_sql` | 本地 SQL 查询（无 UPDATE/JOIN，能力有限） |
| zazaki_tokenizer | `zazaki_tokenizer count "text"` | token 计数（上下文预算） |
| zgrab-cli | `~/Projects/zazaki_grab/build/zgrab-cli --read x.pcap --json` | 抓包/协议分析（实时抓包需先 `~/Projects/zazaki_grab/scripts/setup_cap.sh` 提权） |
| dns_server | `~/Projects/zazaki_dns/build/dns_server dns_server.conf` | 本地 DNS 服务（默认端口 5300，需先启动） |
| qq-analyzer | `curl localhost:8899/status` | QQ 群聊分析控制（需先运行 run.py 服务） |

## MCP 工具（自动可用）

- repo-audit → git 提交前审计（audit_repo_before_commit）
- wechat-download-api → 微信公众号文章获取/检索
- fastaicode-image → 图片生成/编辑
- zazaki-rag → 个人知识库检索（search_knowledge）

## 路由建议

- 连通性/延迟 → zazaki_ping；离线翻译 → zazaki_trans；远程执行 → zssh；传文件 → zazaki_scp
- 本地小库查询 → zazaki_sql；token 预算 → zazaki_tokenizer；抓包分析 → zgrab
- 知识检索 → zazaki-rag；公众号文章 → wechat；图片 → fastaicode-image；提交前 → repo-audit
- 服务型工具（dns_server、qq-analyzer）调用前先确认服务在跑（pgrep / curl /status）
- secrets 纪律：zzzssh/qq-analyzer 相关配置含凭据，输出与交接不得粘贴 token 明文
