#!/usr/bin/env bash
# notify-daily — 把日报推送到手机（ntfy，纯文本）
# 用法: notify-daily.sh [path-to-report] [title]
#   默认报告 ~/docs/daily/$(date +%F).txt；省略 title 时从文件名推导「日报 YYYY-MM-DD」
#   传入 title 可覆盖，如: notify-daily.sh ~/docs/weekly/2026-W34.txt "周报 2026-W34"

TOPIC="zazaki-daily-22277d10"
REPORT="${1:-$HOME/docs/daily/$(date +%F).txt}"
TITLE_ARG="${2:-}"

if [[ ! -f "$REPORT" ]]; then
  echo "日报文件不存在: $REPORT" >&2
  exit 1
fi

# 标题: 优先用第 2 个参数；否则从文件名推导 YYYY-MM-DD.txt → 日报 YYYY-MM-DD
if [[ -n "$TITLE_ARG" ]]; then
  TITLE="$TITLE_ARG"
else
  date_part="$(basename "$REPORT")"
  date_part="${date_part%.txt}"
  TITLE="日报 $date_part"
fi

# 用内嵌 python 把日报文本整理成紧凑的纯文本
BODY="$(python3 - "$REPORT" <<'PY'
import sys, re, os

path = sys.argv[1]
with open(path, encoding='utf-8') as f:
    raw = f.read()

if not raw.strip():
    print('（今日日报为空）')
    sys.exit(0)

out = []
section = None      # 当前小节名
git_items = []      # [Git 状态] 小节的列表项（最多保留前 8 条）
git_total = 0

def flush_git():
    global git_items
    out.extend(git_items[:8])
    if len(git_items) > 8:
        out.append('- ... 共 %d 个仓库待处理' % git_total)
    git_items = []

for line in raw.split('\n'):
    s = line.strip()

    if 'DAILY REPORT' in s:                    # 标题横幅 → 日报 YYYY-MM-DD 周X
        rest = s.replace('DAILY REPORT', '', 1).strip(' —–-')
        out.append('日报 ' + rest)
        continue
    if re.match(r'^[═─]+$', s):                # ═══ / ─── 分隔线 → 跳过
        continue
    if s == '':                                # 空行（后续统一折叠）
        out.append('')
        continue

    m = re.match(r'^\[([^\]]+)\](.*)$', s)     # 小节头 [任务] / [Git 状态] …
    if m:
        if section == 'Git 状态':
            flush_git()
        section = m.group(1)
        out.append('[' + section + ']')
        rest = m.group(2).strip()
        if rest:
            out.append(rest)
        continue

    if re.match(r'^ {2,}\S', line):            # 2+ 空格缩进 → 列表项
        content = s
        if content[:1] in ('-', '•'):
            content = content[1:].strip()
        if section == 'Git 状态':
            path_part, sep, desc = content.partition(':')
            item = '- ' + os.path.basename(path_part.strip())
            if sep:
                item += ':' + desc
            git_total += 1
            git_items.append(item)
        else:
            out.append('- ' + content)
        continue

    out.append(s)                              # 普通文本行

if section == 'Git 状态':
    flush_git()

# 连续空行折叠为单个空行，去掉首尾空行
collapsed = []
prev_blank = False
for l in out:
    if l == '':
        if not prev_blank:
            collapsed.append('')
        prev_blank = True
    else:
        collapsed.append(l)
        prev_blank = False
while collapsed and collapsed[0] == '':
    collapsed.pop(0)
while collapsed and collapsed[-1] == '':
    collapsed.pop()

print('\n'.join(collapsed))
PY
)"
PY_CODE=$?
if [[ $PY_CODE -ne 0 ]]; then
  echo "日报文本转换失败 (python exit $PY_CODE)" >&2
  exit 1
fi

# 超过 2000 字符截断并追加标记
if [[ ${#BODY} -gt 2000 ]]; then
  BODY="${BODY:0:2000}…(截断)"
fi

OUTPUT="$(curl -sfS -H "Title: $TITLE" --data-binary @- "https://ntfy.sh/$TOPIC" <<< "$BODY" 2>&1)"
CODE=$?
if [[ $CODE -ne 0 ]]; then
  echo "推送失败 (curl exit $CODE): $OUTPUT" >&2
fi
exit $CODE
