## AI 坑点

只记录同时满足以下至少两条的坑点：

- 大概率会再次出现
- 漏掉后会明显浪费时间、质量或验证成本
- 单看代码本身不容易直接看出来

边界：gotchas 记录系统运行时的实际行为坑点（"踩到就会出问题"）。
anti-patterns 记录 Agent 行为层面的错误模式（"不该这样做"）。
两者有交叉时，以 anti-patterns.md 为主落点，本文件只保留纯系统行为类坑点。

## 系统行为坑点

### 会话与治理文档

- 压缩/长会话后无显式路由表且不重读入口 → 新任务错误继承上一轮路由与完成口径；修复：路由文件+薄壳重注入，不靠记忆。
- `opencode.json` 漏注入薄壳路由文件（`rules/ai/routing-rules.md`）→ 路由表不进上下文，按需规则无法被激活，静默失效。
- 治理文件删除/合并只查 `.md` 交叉引用不够，须 grep `.sh`/`.py`/`.tsv`/`.json` 硬引用，否则验证脚本静默失败。
- markdown 反引号跨目录引用须写完整相对路径（含目录前缀），否则扫描误报 broken ref。
- 文档中"举例文件名"用反引号会被扫描当相对路径 → FAIL broken cross-references；示例名写普通文本。
- 治理文件引用项目内文件须写完整路径（`~/Projects/<proj>/...`），相对路径按治理仓根解析而 FAIL。
- 导入第三方 skill：SKILL.md 的 @file/支撑文件常未搬运 → 静默失效引用（功能性断链照做必失败）；须查齐全，缺失补文件或删引用，补后递归查兄弟引用并复扫归零。
- doc-drift 缺陷（状态文件 vs requirement、schema 双版本、措辞漂移）不在存在性/结构断言覆盖内；状态文件标"全部完成"可违反冻结 requirement 却过绿门禁 → 补 grep 负向断言（must-not=0 / must-contain≥1）。轮次审查传输错误会吞 subagent 结果，需 task_revive 补跑。
- 治理收敛验证：派全新只读 agent 按入口顺序做合成任务路由判定并引用 file:line；已删除的实验文件名用反引号会被 pre-commit 扫描拦截。
- 补 AGENTS.md 前先确认项目有无 codemap.md：有则指向式，无则写自包含轻量地图；勿指向不存在文件造成断链。
- 实例→模板仓库同步：根级 rsync `--delete` 误删目标独有文件，且非空目录报错后仍删了部分；须分目录精确映射（共享层可 --delete，适配器/独有目录禁用），恢复误删逐文件 `git checkout -- "$f"`；JSONC 去注释不能简单 `//` 正则（误伤 URL）。

### 构建与工具链

- `npx tsc` 未装 typescript 时命中 npm 占位包 → 用 `npx -p typescript tsc`；缺 `@types/node` 报 TS2591；纯语法校验用 `--noCheck`（等价 esbuild），全类型需装 @types/node。
- tsc 报 `moduleResolution=node10 has been removed` → 改 `node16` 或 `bundler`。
- uvx 版 mcp-server-fetch 与 mcp SDK≥2.0 不兼容（McpError→MCPError，旧 import 崩，client 报 `-32000: Connection closed`）→ `uvx --from mcp-server-fetch --with "mcp<2.0.0" mcp-server-fetch`；排查先手动 spawn 看 traceback。
- 离线环境 FetchContent：复用已有 `build/_deps` 缓存源码目录可离线 configure+build；无缓存则从其他 worktree 复制 `<name>-src` 并加 `-DFETCHCONTENT_FULLY_DISCONNECTED=ON`。
- editable install 的 C++ 扩展(.so)在系统库滚动升级后 ImportError（链接版本被替换，非解释器不匹配）→ 重跑 cmake 替换 .so，勿用 LD_LIBRARY_PATH hack；排查 `ldd <pkg>/*.so | grep "not found"`。
- `.doc`（OLE Compound）不能用 Read 读文本，需 olefile + python-venv 提取文本流。
- `git commit <path>` 提交的是该路径的**工作区版本**而非索引：部分提交时带 pathspec 会顺手把同文件里他人未提交的改动带走；正确做法是先 `git hash-object -w` + `git update-index --cacheinfo` 重建索引，再不带 pathspec 执行 `git commit`，最后用 `git diff --cached` 核对范围。
- `repo-audit` 的 `dirty-worktree` / `untracked-file` 是整树级 block：仓库存在任何无关在飞改动时必然 FAIL 且无法清零，它是发布前门禁，不是「本次提交是否有问题」的判据；单次提交用 `git diff --cached` 校验范围，并在汇报中保留审计 FAIL 与既有脏项，不要为过审计去动无关文件。

### Ansible 与部署编排

- 离线部署的"离线 copy"任务无条件覆盖先前在线下载的正确二进制 → 须加 `when: host_arch.stdout == 'x86_64'`；只改下载 URL 无效。
- 改 `docker run` 镜像名前须核对离线 tar 的 manifest.json RepoTags（`tar -xOf <image>.tar manifest.json`），否则拉取失败。
- 多个内层 tarball 的顶层路径前缀可能不一致（有的带 `./`，有的不带）→ 统一 `--strip-components=1` 会剥掉目录名致文件落错层、PATH 失配；正确统一不 strip（`./` 被 tar 自动忽略）。验证 `tar tjf/tzf <tarball> | sed 's|/.*||' | sort -u` 看顶层前缀，strip 前确认前缀一致。
- 任务拆 async 启动+async_status 等待、或给 docker pull 加"镜像已加载则跳过"门控时，启动/等待/检查任务须带相同 `tags`；否则 `--tags X` 只跑部分，`jid`/`when` 引用未定义变量 FAIL。
- Jinja2 渲染 bash：`${#hostarr[@]}` 被当注释 `{#` → "Missing end of comment tag"（`--syntax-check` 不报，渲染才炸）；修复 `{{ '${#' }}hostarr[@]}`；验证须实际 render（未渲染 .j2 的 YAML 校验误报 `- {{ var }}`）。
- 多节点集群 playbook 须把"每节点初始化"（可 serial:1）与"集群拉起"（须并行，各节点同时启动才成 quorum）拆两个 play，否则先完成节点无限等 quorum；拉起幂等不能用"进程已存在就跳过"（孤立进程无 quorum），须 pkill 陈旧进程后统一重启。
- 集群端口改动须整段核对 20000-20002（控制/心跳/DCC）；只放行部分会漏跨节点通信 → 选举卡死（各节点只投自己、term 停滞、控制组件全 Standby）；放行后自动选举并 rebuild 备机，无需重启容器或清数据。
- VIP 跟随主节点不能用"静态 MASTER+权重"（覆盖不了任意节点为主）；正确：全节点同 base priority + 全 BACKUP + 健康检查负权重（主满权/非主降权，任意主必赢）；须保留抢占（nopreempt 使主变化时 VIP 不跟随）。
- keepalived 的 `-t` 语法检查在配置含 vrrp_script 且未启用 script_security 时固定返回 exit 6（SECURITY VIOLATION，原配置也一样）→ 不能把 `-t` 当通过门禁，验证改用 systemctl reload + 观察 VIP/state 日志；BACKUP 节点 reload 后启动瞬间会短暂进入 MASTER 并绑 VIP、收到高优先级 advert 后自动降级，属正常瞬态。
- 数据库+Nacos 全新部署 crash-loop 前提：VIP/keepalived 先于 Nacos（否则 NoRouteToHost）；数据源 host 指 VIP 而非固定节点 IP；防火墙端口须 `immediate: yes`（只写 permanent 则运行时 zone 无端口）。
- schema 初始化：须先建业务用户与 B 兼容库；schema 不自动建，须显式执行镜像插件自带 SQL（12 表），否则报误导性 `No DataSource set`；表 owner 须业务用户（初始用户应用 permission denied），需 `GRANT ALL ON SCHEMA public` + `ALTER SCHEMA public OWNER TO <user>`；DDL 只能 Primary 本机（Standby 只读、初始用户禁远程），容器内 `su - <user> -c` 本地 trust；内层 SQL 单引号经多层 shell 被吞，脚本拷入容器 `su - <user> -c "bash /tmp/x.sh"` 单层引号执行。
- gsql 不读 PGPASSWORD，须 `-W "pass"`；三重静默（PGPASSWORD+重定向+无条件成功输出）掩盖密码不匹配，schema 失败须 exit 1；`password_reuse_time=60` 默认禁 60 天内重设相同密码，须临时 `ALTER SYSTEM SET password_reuse_time=0`+reload 再恢复；幂等用"业务用户能真实 SELECT 目标表"的 canary（表存在≠可查）；诊断先分 DB 阶段还是集群阶段，"No DataSource set" 查 `SELECT tableowner FROM pg_tables`。
- 主备切换后 JDBC 池可能永久卡死：被杀连接致 Hikari 报 "Connection is not available/reset"、服务端 0 连接无新连接、读配置返回陈旧值 → 只能重启应用容器，维护窗口须纳入切换后重启；登录式 su 下 PGPASSWORD 不生效，须 `echo pw | gsql` stdin 或本地 trust；初始用户远程被拒，业务验证用非初始用户。

### 容器与网络

- "wrapper 调 original"若 original 会被其他入口再次触发 → 递归 fork bomb；替换前排查 original 所有触发入口，被替换脚本换纯 no-op（只打印 exit 0），绝不 subprocess 调 _orig。
- 登录式 `su - <user> -c "cmd"` 重置 PATH/环境变量，export 放 su 之前无效；须放进 su -c 双引号内、命令之前，并用 `\$PATH` 让登录 shell 展开。
- 容器内执行数据库控制命令的规范引号模式须带 `LD_LIBRARY_PATH=<app/lib>:<tool/lib>:/usr/lib64`，否则报动态库缺失（连查询都挂）；主机可能只有 standalone `docker-compose` 而无 `docker compose` v2 插件，须用前者。
- VM 重启后 docker 自定义外部网络丢失 → 引用旧网络 ID 的容器 Exited(255)，`restart=always` 与普通 `docker-compose up -d` 无法自愈（判定配置未变、复用旧容器），须 `docker-compose up -d --force-recreate`；恢复 SOP：`docker network create` → 按依赖序 `up -d --force-recreate` → 健康检查；某些镜像 CLI 脚本不在 PATH，需全路径。
- Docker data root 可能不在 `/var/lib/docker`（`--data-root`）→ 日志采集器挂默认路径只拿空目录；须用变量渲染实际 data-root 挂载（容器内路径固定）；排查 `docker info | grep "Docker Root Dir"`；日志后端 label 只列保留窗口内有过日志的容器（安静服务不出现属正常），老 backlog 被 reject_old_samples 拒收，判断管道通通用"有活跃日志的容器"查询。
- WSL2 mirrored+autoProxy 让新进程继承 Windows 系统代理；代理 fake-ip/nameserver-policy 通配可把内网域名解析到死地址 → 流式中断；修复 nameserver-policy 指向实测可达 IP；排查：对比直连 vs 代理解析 IP、`/dev/tcp/ip/port` 扫可达性、`ps`+`/proc/PID/environ` 查注入 proxy env；代理配置改前备份、改后重载。
- 某 JS 运行时在 WSL2 mirrored+TUN 下访问局域网 API 流式中断（connection reset / SSE read timed out），而 curl/Node 完整——运行时与 TUN 的 LAN 兼容问题，HTTP_PROXY workaround 对 SSE 无效；修复：TUN profile 加 `route-exclude-address: <lan>/24` 绕过、provider 加 chunkTimeout；代理配置三坑：`config.yaml` 是渲染副本重启被覆盖、`shared_preferences.json` 重启被内存覆盖、只有 `profiles/<id>.yaml` 是正确修改点（改后重启）；bypassDomain 只对系统代理生效，对 TUN 无效（TUN 排除须用 tun.route-exclude-address）。

### 数据库与复制

- Kafka `--generate --topics-to-move-json-file` 从不提升复制因子（只再均衡现有副本）；提升 RF 须手工构造 reassignment JSON（每 partition 列足量 broker）再 `--execute`，且 `log_dirs` 数组长度须等于 `replicas` 长度，否则报 "Size of replicas list ... different from size of log dirs list"。
- Galera 中 `gtid_domain_id` 须与 `wsrep_gtid_domain_id` 分离（相同不保证本地事务用该 domain）；跨机房 DDL 可同时经 Galera 与异步路径抵达，重复 GTID 触发 1950 并停 SQL 线程；确认已由 Galera 应用后才可跳过单个重复事件，并复核线程与错误号。
- GTID domain 修复后重建配置模板可能仍留旧 domain，只核对运行时变量会漏，后续重建回退错误 domain；验收须同时核对运行时变量与持久化模板。
- MariaDB 11.4 无 `mysql.slave_master_info` 表（`master_info_repository` 也不存在，元数据存文件 master.info），用它判断通道报 1146；正确判据是 `SHOW SLAVE STATUS` 是否返回数据行（空输出=无通道）。
- `SET GLOBAL gtid_slave_pos` 有 errno 1948 约束：新值须覆盖本地 binlog 中所有 domain（含 domain0），不能删空；清除残留远端 domain0 须替换成本地 binlog 实际存在的 domain0 GTID。

### C++ 并发与生命周期

- 线程引用容器内对象 UAF：用 `shared_ptr` 捕获替代裸迭代器/引用（`detach()`+`erase()` 后线程仍跑=UAF）；`stop()` 须先置 cancel 标志再在锁外 join，持锁 join 与完成回调死锁。
- 空闲清理回收连接进池并关 fd 前须先摘除调度器 epoll/`fd_to_coroutine_` 映射（fd 复用+陈旧事件唤醒旧协程=跨连接内存破坏）；Connection 需引用计数或协程引用期不入池；cleanup 不得 erase 仍被 ready queue 引用的协程（加 queued 标志，pop 时再摘）。
- 持锁跨越可能挂起的底层调用（start() 持锁到 pcap_activate 完成）而 stop()/query() 抢同锁 → 主线程无限阻塞、进程冻结；修复：可挂起调用放后台线程 + atomic startup_done + 状态占位 + 轮询以 running 为门，退出时未就绪则 detach 并 `std::_Exit(0)` 跳过局部析构；startup_done 置位须在释放锁后（release 序）。
- `pcap_next_ex` 不保证读超时：TPACKET_V3 只退休非空块，装 BPF 且无匹配流量时块恒空、`poll(-1)` 永不返回，`pcap_set_timeout` 形同虚设；持锁调用且 status()/stop() 抢同锁则永久死锁；修复：worker 用 `pcap_get_selectable_fd`+有界 `poll(100ms)` 等待，仅 fd 可读时持锁调用。
- `pcap_activate` 正数返回是警告非错误（仅负数致命），`if (act != 0)` 会把警告当失败拒绝启动；虚拟化环境 127.0.0.1 可能路由到非 lo，硬编码 lo 会静默抓空，用 `ip route get 127.0.0.1` 动态解析（失败回退 lo）。
- 离线读包循环 `--count` 的 break 放在过滤 `continue` 之后时，全被过滤会读到 EOF 超上限；读取上限须在过滤 continue 之前检查；`seek_to(total)`（目标=文件包总数）返回 true 并定位 EOF、`next()` 返回 false，`seek_to(>total)` 返回 false——据此区分空页（offset==total）与越界（offset>total）。
- 缺系统库无法链接时，为缺失库写最小 stub 头（放 /tmp 不入库）复用真实系统头，跑 `g++ -fsyntax-only -std=c++20 -Wall -Wextra -Werror` 做全文件类型/语法检查作为离线替代；UAF/生命周期改动仍需逐路径复核所有权。

### 终端渲染与 UI

- 终端"真实图片"渲染（真彩/Sixel/Kitty）验证须分配 PTY（`script -qec cmd /dev/null`）；重定向/管道走无色降级会误判，PTY 输出含 `\r\n` 需先剥 `\r`；只走管道的 smoke 仅覆盖无色路径；zsh 下 `grep '\x1b\[38;2;'` 报"未匹配的 ["，ANSI 计数改用 `grep -F` 或 python count。
- 用 `std::string::size()` 按字节算含 UTF-8 多字节字符的行宽做布局分派会误触发分支且无报错；ASCII 行字符数=字节数，宽字符须按字符（mbrtowc/wcwidth）而非字节。
- 手工拼 ASCII block 艺术字行宽易参差，`left_w=max(行宽)` 决定信息列起始 → 视觉漂移；用脚本按固定间距拼接并断言每行等宽；C++ 无符号 `gap = cols/2 - left_w` 在 `cols/2 < left_w` 时下溢，虽经模运算"意外"正确但空行/满宽行 pad 目标不一致 → 信息列错位，改显式 `info_start = max(left_w+2, cols/2)` 统一 pad。
- Sixel 验证：ImageMagick 的 Sixel 读取器有 bug（自产 .six 解码全黑只留尺寸），用它 compare 假阳性，应自写标准解码器对比；调色板须用标准 `#N;2;R;G;B`（0-100），`;3;`（0-255）部分解码器拒绝（全黑）；`!N` RLE 重复语义有分歧（N+1 vs N 次），跨实现最稳不用 RLE 逐像素输出；DA1 响应可能丢开头 ESC，探测须容忍带/不带 `\x1b`；Sixel 支持=DA1 参数含 '4'。
- 某 TUI 框架新版 API 差异：ScreenInteractive 改名 App（`App::Fullscreen()`+`app.Loop(root)`）；Menu 不自动滚动，须 `menu->Render() | vscroll_indicator | frame`；EntryState 选中行是 `state.active` 非 `.selected`；vbox/hbox flex 按 `min_size × flex_factor` 比例，需定比例用 `size(HEIGHT, EQUAL, n)`；管道 `'\n'` 不映射 Event::Return（真终端 `'\r'` 才映射），Enter 放顶层 CatchEvent；空 Menu 不可 Focusable 使 j/k 被当焦点切换，j/k 移动选择须顶层 CatchEvent 显式处理；惰性派生状态只在 render 构建会让事件回调读旧值，抽 rebuild 函数供 render 与 action 共用。
- 某 TUI 框架 Menu 每次 OnRender 重建全部条目（无虚拟化），大列表塞入拖垮布局；解法"切片视图"只渲染 `[scroll, scroll+viewport)` 可见行，滚动键顶层手动调 scroll 并夹紧，滚动条自绘——成本 O(视口)；配套：多标签页按键按当前 tab 作用域分发，分析型 tab 重算用「进入即算+live 节拍+宽度变化」门控，Menu transform 按行着色用控制字符编码字段，抽公共函数供 transform 与切片视图共用。

### 协议与格式解析

- Python `http.client` 的 putheader/putrequest 只接受 latin-1 头（非 ASCII 头 UnicodeEncodeError），`conn.sock.sendall` 原始写后 getresponse 报 ResponseNotReady，`urllib.request` 同样；可靠做法：原生 socket+ssl 构造原始请求字节，头按 UTF-8 发送，读响应直到 Connection: close。
- 某事件 API 的 `/json?poll=1` 返回形状不稳定：1 条返回单对象，多条是 NDJSON 流，单次 `json.load` 报 Extra data；须按行解析并过滤 `event=="message"`。
- 环形缓冲快照做流式输出不能用"快照下标>=已打印数"去重（逐出旧包后下标永久错位、输出静默）；用会话级全局序号减快照大小推逐出偏移（`evicted = captured - snapshot.size()`），起始下标=`printed - evicted`（钳 0），每轮 `printed = captured`；统计 NDJSON 日志包数须逐行 `json.loads` 且仅计数 dict 行。
- pcapng 块布局：每块尾部须重复 total_len（含两个 4B 字段），读 body(tl-12) 后还要消费尾部 4B；SHB 类型 0x0A0D0D0A 是字节回文，字节序靠 body 的 byte-order magic 判断（大端 BOM 字节为 1A2B3C4D）；EPB 数据起始须在跳 4 字节对齐填充前记录，否则偏移被 pad 污染。
- 原始套接字被封锁的环境（`socket(AF_PACKET)`→Errno 1）即使二进制有 setcap 仍 pcap_activate 失败；实时抓包端到端验证做不了，只能以设备选择/诊断消息为 pass 标准，验证前先探测环境；`pgrep -f "<name>"` 会匹配自身包装命令行与子 shell 造成孤儿进程误报，验证无残留用 `pgrep -x <procname>`。

### 脚本与子进程

- python 子进程验证服务器时 `proc.stderr.read()` 阻塞到进程退出，进程存活时读=无限 hang（误判卡死）；应重定向 stderr 到文件或用 `select.select` 限时读；子进程 env 须显式传 key（`os.environ` 无刚写入变量），空 key 让客户端走 MissingApiKey 快速失败。
- 空跑判定不能看完成/失败数是否为 0（历史已完成文件夹长期存在），要统计待办数：待办==0 且 rc==1 才是正常空跑（静默 exit 0）；待办>0 且 rc==1 且无进展是真实失败，须传播非零退出码。
- 后台 agent 返回 completed 但结果文本为空时，先查磁盘产物，用 task_revive 复用同会话（上下文仍在）而非新建会话重发；审查类任务在某 agent 类型连续空结果时改用 oracle；`(cmd &)`+pkill 组合会让外层 shell 挂住到 timeout，冒烟测试应前置输出并用 timeout 包裹。
- ssh 远端 `pkill -f <pattern>` 会匹配并杀死执行命令的 shell 自身（命令串含 pattern），表现为无输出、未清理，用字符类防自匹配 `pkill -9 -f "console-produce[r]"`；逐条启动重型进程不可用于循环测试（每次启动开销大），用常驻管道+后台消费者写文件，单分区 topic 保证顺序。

### 数据与内容处理

- Godot headless 三坑：autoload 脚本不能加 class_name（报 "Class hides an autoload singleton"），无 class_name 的 autoload 在 `--script` 模式无法类型推断，须 `const X = preload("res://...gd")` 再 new；新增 class_name 后须先 `--headless --import` 刷新全局类缓存；4.4+ 自动生成 `*.uid` 应随 src 提交（.gitignore 只加 `.godot/`、`*.import`）；`--script` 结束的 ObjectDB leaked/resources in-use 警告 exit 0 属正常。
- 第三方数据源"授权声明"≠数据质量；多源交叉核对后再选 base；多读音条目用"取第一个变体+显式 override+同形异义行保留完整表达式"归一化。
- 服务实际加载的配置文件可能非默认路径（如 bin/ 下而非 conf/），用陈旧副本调 API 报密钥错误；API 端口可能非默认，某些版本本地地址也不豁免密钥校验；验证须用实际生效路径与端口。
- 长卷网文按章节段落表推进时实际写作会提前消耗靠后段内容，后续须优先对齐"已写概述行+各章结尾钩子"而非表格原文，否则重复或失锚；格式检查脚本对注释块与标题冒号必报 failure 但属豁免，批量验证用 `head` 截断会漏后续失败项，须逐章完整跑。
- libssh 的 `SSH_OPTIONS_STRICTHOSTKEYCHECK` 单独设置不会在 `ssh_connect()` 内强制执行，未知/变更 host key 仍握手成功，须连接后显式 `ssh_session_is_known_server()` 并按状态硬拒绝，否则默认 MITM；选项枚举名是 `SSH_OPTIONS_KNOWNHOSTS`（KNOWN 与 HOSTS 间无下划线）。
- 正文编辑工具会把中文弯引号转写成 ASCII 直引号，且 oldString 含弯引号时匹配失败；含引号内容应改用 python 脚本替换而非编辑工具，整文件写入同样会转写；写完跑引号归一校验（弯引号左右计数相等+直引号 0+半角标点 0）。
- 文风检查脚本的"洞察路标"计数来自软词集（真正/本质上/核心是/关键在于/这意味着等），超阈值才进警告；软词实义用法与标题/注释块冒号属格式豁免；解读只看"需要修改/需要人工判断"区块，勿被汇总行计数误判；脚本报告"需要修改"时退出码非 0，用 `&&` 串联的结构校验会被短路，验证命令须独立跑。
- 符号化/生僻术语领域 RAG：embedding 余弦 + n-gram 关键词加权混合检索优于纯 embedding；关键词用查询的 2-4 字连续子串（n-gram）而非分词整词，对换行打断的术语鲁棒。
- OCR 只对现代横排印刷扫描件有效，竖排古籍/抄本不可用；`len()` 返回字符数、`wc -c` 返回 UTF-8 字节数（中文 1 字符≈3 字节），检查 OCR 丢内容必须用 `wc -c`；无对应 Python 版本的 torch wheel 时可用纯 onnxruntime 的 embedding 替代；工具输出偶发串台，重要事实用 `wc -c`/`rg`/`read` 交叉验证。
- 本地脚本复用应用配置里的 LLM provider 时 apiKey 可能是 `{env:VAR}` 字面量（grep 提取拿到占位符导致 Invalid token），须用 `printenv`/进程 environ 取实际值；该 key 可能只对内网网关有效，对官方端点 401。
- 长中文文档（>约 15KB）单次 write 会 JSON 截断失败且报错被吞，须按章节拆 `_partN.md` 分段写再 `cat` 合并；逐页标记交付物必须先用"章节锚点页"锁定区间再逐页编号，凭感觉编号会漂移；校验 `grep -oP '^- P\K[0-9]+' file | sort -n | uniq -c` 全为 1 且首尾为 1/N。
- 同步降频门控用「逻辑 tick 奇偶」而非「同步 tick 发射计数」会饿死一半对象（固定奇偶相位才发送，不匹配对象位置增量永不发，客户端靠全量同步瞬移）；正确用 per-object 发射计数器（每次可发送 +1，满 stride 放行）；小地图阈值几乎覆盖全图，叠加客户端 snap 阈值会放大卡顿。
- 协议路径迁移（消息从 A 改走 B）后，依赖旧路径的集成测试静默变红（断言恒空但不报编译错，运行期 FAIL 且措辞误导）；改动消息路由后须 grep 所有断言该消息的测试并同步对齐；smoke test 注意 UDP 缓冲堆积（绕过预算的包污染后续采样窗口，须先排空再采样）。
- LSP 未配置 include/compile_commands 时对 C++ 头文件报 file not found 并级联刷大量 undeclared identifier 假阳性，看着像整文件崩坏，但真实构建通过；判定：首错是 header not found 且后续全是级联符号错时以真实构建为准，改代码后先跑真实 build 再判断。
- 多 lane 并发改同一共享文件时合并会"结构性并置但逻辑缺环"（对方 handler 落在聚合块内但入口条件未含其 flag → 死代码，无编译/运行报错，只有端到端测试暴露）；编辑共享文件前重读当前状态，合并后把双方模式都端到端跑一遍，看"handler 是否真的可达"而非 flag 解析。
- `OPENCODE_CONFIG=<template>` 会与常规全局配置面叠加，不能证明模板可独立加载；验证 standalone 用隔离 `XDG_CONFIG_HOME`；schema 拒绝 `_comment` 自定义键，JSONC 说明用真正行注释。
