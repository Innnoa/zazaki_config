#!/usr/bin/env python3
"""wechat-feeds — 定时抓取已配置公众号的最新文章并保存到本地。

配置文件: ~/.config/opencode/wechat-feeds.json
  {"feeds": [{"name": "example-account", "fakeid": "xxx", "limit": 5}]}

保存目录: ~/docs/wechat/<name>/YYYY-MM-DD_<slug>.md
已存在的文件直接跳过（重复运行幂等）。
"""

import json
import re
import socket
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path

BASE_URL = "http://localhost:5000"
CONFIG_PATH = Path.home() / ".config" / "opencode" / "wechat-feeds.json"
OUTPUT_DIR = Path.home() / "docs" / "wechat"
NTFY_URL = "https://ntfy.sh/zazaki-daily-22277d10"
_NTFY_PARTS = urllib.parse.urlparse(NTFY_URL)
_NTFY_HOST = _NTFY_PARTS.hostname
_NTFY_PATH = _NTFY_PARTS.path


def push_ntfy(body, title="公众号抓取"):
    """POST 原始字节到 ntfy。必须保留换行：直接发送 bytes，不做 url-encode。

    标题为中文，http.client 的 putheader 只接受 latin-1（会抛 UnicodeEncodeError），
    因此用原生 socket 构造原始 HTTP 请求字节，头部按 UTF-8 编码（ntfy 按 UTF-8 读取）。
    任何失败只打 warn，绝不抛异常——cron 静默语义，退出码始终为 0。
    """
    payload = body.encode("utf-8")
    title_b = title.encode("utf-8")
    request = (
        f"POST {_NTFY_PATH} HTTP/1.1\r\n"
        f"Host: {_NTFY_HOST}\r\n"
        "Content-Type: text/plain; charset=utf-8\r\n"
        f"Content-Length: {len(payload)}\r\n"
        "Connection: close\r\n"
    ).encode("ascii") + b"Title: " + title_b + b"\r\n\r\n" + payload
    try:
        ctx = ssl.create_default_context()
        with socket.create_connection((_NTFY_HOST, 443), timeout=15) as sock:
            with ctx.wrap_socket(sock, server_hostname=_NTFY_HOST) as ssock:
                ssock.sendall(request)
                resp = b""
                while True:  # Connection: close → 读到连接关闭即响应结束
                    chunk = ssock.recv(4096)
                    if not chunk:
                        break
                    resp += chunk
        status = int(resp.split(b"\r\n", 1)[0].split()[1])
        if status >= 400:
            print(f"[warn] ntfy 推送失败: HTTP {status}", file=sys.stderr)
    except Exception as e:  # noqa: BLE001 — 通知失败不应影响抓取结果或退出码
        print(f"[warn] ntfy 推送失败: {e}", file=sys.stderr)


def fetch_json(url, timeout=15):
    """GET 并解析 JSON；非 200 或解析失败抛异常。"""
    with urllib.request.urlopen(url, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def make_slug(title):
    """标题 → 安全文件名: 去除非字母数字及 -_.; 空白折叠; 最长 40 字符。"""
    slug = re.sub(r"[^A-Za-z0-9\-_.]+", "-", title)
    slug = re.sub(r"-{2,}", "-", slug).strip("-._")
    slug = slug[:40].strip("-._")
    return slug or "untitled"


def fmt_date(ts):
    """unix 时间戳 → YYYY-MM-DD；无效值返回空串。"""
    if not ts or ts <= 0:
        return ""
    return datetime.fromtimestamp(ts).strftime("%Y-%m-%d")


def process_feed(feed):
    """抓取单个公众号，返回 (总数, 新增数, 是否请求出错)。"""
    name = feed.get("name", "unnamed")
    fakeid = (feed.get("fakeid") or "").strip()
    limit = int(feed.get("limit") or 5)

    if not fakeid:
        print(f"[warn] 跳过 {name}: fakeid 为空", file=sys.stderr)
        return 0, 0, False

    url = f"{BASE_URL}/api/public/articles?{urllib.parse.urlencode({'fakeid': fakeid, 'begin': 0, 'count': limit})}"
    try:
        data = fetch_json(url)
    except (urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError) as e:
        print(f"[warn] 抓取 {name} 失败: {e}", file=sys.stderr)
        return 0, 0, True

    if not data.get("success"):
        print(f"[warn] 抓取 {name} 失败: {data.get('error') or '未知错误'}", file=sys.stderr)
        return 0, 0, True

    articles = ((data.get("data") or {}).get("articles")) or []
    feed_dir = OUTPUT_DIR / name
    feed_dir.mkdir(parents=True, exist_ok=True)

    added = 0
    for article in articles:
        title = article.get("title") or "(无标题)"
        link = article.get("link") or ""
        date = fmt_date(article.get("create_time") or article.get("update_time")) or datetime.now().strftime("%Y-%m-%d")
        digest = (article.get("digest") or "").strip()

        fname = f"{date}_{make_slug(title)}.md"
        out_path = feed_dir / fname
        if out_path.exists():
            continue  # 幂等: 已存在则跳过

        lines = [f"# {title}", f"原文链接: {link}", f"日期: {date}"]
        if digest:
            lines.append("")
            lines.append(digest)
        out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
        added += 1

    return len(articles), added, False


def main():
    if not CONFIG_PATH.exists():
        print(f"配置文件不存在: {CONFIG_PATH}，请先配置公众号")
        return 0

    try:
        config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as e:
        print(f"[warn] 配置文件解析失败: {e}", file=sys.stderr)
        return 0

    feeds = config.get("feeds") or []

    # 后端健康检查：连接不上则提示并退出（cron 静默语义）
    try:
        fetch_json(f"{BASE_URL}/api/health")
    except (urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError):
        print("后端未启动: 请先运行 docker compose up -d (backend)", file=sys.stderr)
        return 0

    total_new = 0
    errored = 0
    new_lines = []  # 新增>0 的 feed，逐行进推送正文
    for feed in feeds:
        name = feed.get("name", "unnamed")
        n, added, is_error = process_feed(feed)
        total_new += added
        if is_error:
            errored += 1
        if added > 0:
            new_lines.append(f"  {name}: 新增 {added} 篇")
        print(f"抓取 {name}: {n} 篇 (新增 {added})")

    print(f"共新增 {total_new} 篇 → {OUTPUT_DIR}/")

    # 推送规则
    if total_new > 0:
        body = f"公众号抓取完成: 共新增 {total_new} 篇"
        if new_lines:
            body += "\n" + "\n".join(new_lines)
        push_ntfy(body)
    elif feeds and errored == len(feeds):
        # 无新增且所有 feed 都请求出错（可能限频）→ 警告推送
        push_ntfy(f"公众号抓取失败: 全部 {len(feeds)} 个公众号请求出错（可能限频）")
    # else: 无新增且无错误 → 静默不推送，避免每日噪音
    return 0


if __name__ == "__main__":
    sys.exit(main())
