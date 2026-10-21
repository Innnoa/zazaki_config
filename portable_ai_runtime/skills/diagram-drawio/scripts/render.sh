#!/usr/bin/env bash
# render.sh — drawio XML → PNG 渲染封装
# 用法: render.sh <input.drawio> [output.png]
set -euo pipefail

INPUT="${1:?用法: render.sh <input.drawio> [output.png]}"
OUTPUT="${2:-${INPUT%.drawio}.png}"
if [[ ! -f "$INPUT" ]]; then echo "错误: 输入文件不存在: $INPUT" >&2; exit 1; fi

# 探测 drawio CLI(候选路径按优先级)
CANDIDATES=(
  "/mnt/c/Users/hzj/AppData/Local/Programs/draw.io/draw.io.exe"
  "/mnt/c/Program Files/draw.io/draw.io.exe"
  "$(command -v drawio 2>/dev/null || true)"
)
DRAWIO=""
for c in "${CANDIDATES[@]}"; do
  if [[ -n "$c" && -x "$c" ]]; then DRAWIO="$c"; break; fi
done
if [[ -z "$DRAWIO" ]]; then
  echo "错误: 未找到 drawio CLI。请检查 Windows 是否安装 draw.io 并重试。" >&2
  exit 1
fi

echo "drawio: $DRAWIO"
echo "渲染: $INPUT -> $OUTPUT"
"$DRAWIO" --export --format png --output "$OUTPUT" "$INPUT"
echo "完成: $OUTPUT"
